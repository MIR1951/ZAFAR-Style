import Foundation
import Supabase

@MainActor
class AppointmentViewModel: ObservableObject {
    @Published var appointments: [Appointment] = []
    @Published var timeSlots: [TimeSlot] = []
    @Published var selectedDate: Date = Date()

    private let client = SupabaseManager.shared.client
    private var realtimeChannel: RealtimeChannel?

    init() {
        Task {
            await fetchAppointments(for: selectedDate)
        }
    }

    deinit {
        Task {
            await unsubscribeFromAppointments()
        }
    }

    func handleRefresh() async {
        await fetchAppointments(for: selectedDate)
    }

    func fetchAppointments(for date: Date) async {
        await unsubscribeFromAppointments()

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        do {
            let appointments: [Appointment] = try await client.database
                .from("appointments")
                .select()
                .gte("appointment_time", value: startOfDay.ISO8601Format())
                .lt("appointment_time", value: endOfDay.ISO8601Format())
                .execute()
                .value

            self.appointments = appointments
            generateTimeSlots()
            subscribeToAppointmentChanges()
        } catch {
            print("🔴 ERROR fetching appointments: \(error.localizedDescription)")
        }
    }

    private func subscribeToAppointmentChanges() {
        realtimeChannel = client.realtime.channel("public:appointments")

        realtimeChannel?
            .on("postgres_changes",
                filter: ChannelFilter(event: "*", schema: "public", table: "appointments")
            ) { [weak self] message in
                self?.handleRealtimePayload(message)
            }

        Task {
            await realtimeChannel?.subscribe()
        }
    }

    private func handleRealtimePayload(_ message: RealtimeMessage) {
        guard let event = message.payload["type"] as? String else { return }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        switch event {
        case "INSERT", "UPDATE":
            if let recordJSON = try? JSONSerialization.data(withJSONObject: message.payload["record"] ?? [:]),
               let appointment = try? decoder.decode(Appointment.self, from: recordJSON) {

                DispatchQueue.main.async {
                    if let index = self.appointments.firstIndex(where: { $0.id == appointment.id }) {
                        self.appointments[index] = appointment
                    } else {
                        self.appointments.append(appointment)
                    }
                    self.appointments.sort { $0.appointmentTime < $1.appointmentTime }
                    self.generateTimeSlots()
                }
            }

        case "DELETE":
            if let oldJSON = try? JSONSerialization.data(withJSONObject: message.payload["old_record"] ?? [:]),
               let appointment = try? decoder.decode(Appointment.self, from: oldJSON) {

                DispatchQueue.main.async {
                    self.appointments.removeAll { $0.id == appointment.id }
                    self.generateTimeSlots()
                }
            }

        default:
            break
        }
    }

    private func unsubscribeFromAppointments() async {
        try? await realtimeChannel?.unsubscribe()
        realtimeChannel = nil
    }

    func addAppointment(for timeSlot: TimeSlot, name: String, phone: String, uid: UUID) async {
        let newAppointment = Appointment(
            id: 0,
            name: name,
            phone: phone,
            appointmentTime: timeSlot.date,
            status: "pending",
            userId: uid
        )

        do {
            try await client.database
                .from("appointments")
                .insert(newAppointment, returning: .minimal)
                .execute()
        } catch {
            print("🔴 ERROR adding appointment: \(error.localizedDescription)")
        }
    }

    func updateAppointmentStatus(appointmentId: Int, newStatus: String) async {
        do {
            try await client.database
                .from("appointments")
                .update(["status": newStatus])
                .eq("id", value: appointmentId)
                .execute()
        } catch {
            print("🔴 ERROR updating status: \(error.localizedDescription)")
        }
    }

    private func generateTimeSlots() {
        let calendar = Calendar.current
        var slots: [TimeSlot] = []

        let now = Date()
        let isToday = calendar.isDateInToday(selectedDate)

        for hour in 9..<18 {
            for minute in [0, 30] {
                if let time = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: selectedDate) {
                    if isToday && time < now { continue }

                    let isBooked = appointments.contains {
                        abs($0.appointmentTime.timeIntervalSince(time)) < 60
                    }

                    slots.append(TimeSlot(date: time, isBooked: isBooked))
                }
            }
        }

        self.timeSlots = slots
    }
}
