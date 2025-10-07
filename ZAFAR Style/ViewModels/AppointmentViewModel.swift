import Foundation
import Supabase

@MainActor
class BarberProfileViewModel: ObservableObject {
    @Published var barber : Barber?
    @Published var appointments: [Appointment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client: SupabaseClient
    private var channel: RealtimeChannelV2?

    init(supabaseURL: String, supabaseKey: String) {
        client = SupabaseClient(
            supabaseURL: URL(string: supabaseURL)!,
            supabaseKey: supabaseKey
        )
    }
    func fetchBarber(id: UUID) async {
        isLoading = true
        errorMessage = nil

        do {
            let b: Barber = try await client
                .from("barbers")
                .select("id, display_name, city, rating, reviews, address, opening_hours, gallery, created_at"
                )
                .eq("id", value: id.uuidString)
                .single()
                .execute()
                .value

            self.barber = b
            print("Fetched Barber:", b)
        } catch {
            errorMessage = error.localizedDescription
            print("fetchBarber error:", error)
        }

        isLoading = false
    }




    

    func fetchAppointments(for barberID: UUID) async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await client
                .from("appointments")
                .select("id, barber_id, user_id, start_at, end_at, status")
                .eq("barber_id", value: barberID.uuidString)
                .order("start_at", ascending: true)
                .execute()

          let data = response.data

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let appts = try decoder.decode([Appointment].self, from: data)
            appointments = appts
        } catch {
            errorMessage = error.localizedDescription
            print("Fetch error:", error)
        }
        isLoading = false
    }

    func subscribeToChanges(barberID: UUID) {
        // Agar kanal oldin ochilgan bo‘lsa, unsubscribe qiling
        if let ch = channel {
            Task { await ch.unsubscribe() }
        }

        // Kanal yaratish
        channel = client.realtimeV2.channel("appointments-changes")
        guard let ch = channel else {
            print("❌ Failed to create channel")
            return
        }

        // INSERT
        ch.onPostgresChange(
            AnyAction.self,
            schema: "public",
            table: "appointments",
            filter: "barber_id=eq.\(barberID.uuidString)"
        ) { change in
            print("🔄 INSERT change event:", change)
            Task { await self.fetchAppointments(for: barberID) }
        }

        // UPDATE
        ch.onPostgresChange(
            AnyAction.self,
            schema: "public",
            table: "appointments",
            filter: "barber_id=eq.\(barberID.uuidString)"
        ) { change in
            print("🔄 UPDATE change event:", change)
            Task { await self.fetchAppointments(for: barberID) }
        }

        // DELETE
        ch.onPostgresChange(
            AnyAction.self,
            schema: "public",
            table: "appointments",
            filter: "barber_id=eq.\(barberID.uuidString)"
        ) { change in
            print("🔄 DELETE change event:", change)
            Task { await self.fetchAppointments(for: barberID) }
        }

        Task {
            do {
                _ = try await ch.subscribe()
            } catch {
                print("⚠️ Subscribe error:", error)
            }
        }
    }
    func bookAppointment(barberID: UUID, start: Date, end: Date) async {
           do {
               let iso = ISO8601DateFormatter()
               let vals: [String: AnyJSON] = [
                   "barber_id": .string(barberID.uuidString),
                   "start_at": .string(iso.string(from: start)),
                   "end_at": .string(iso.string(from: end)),
                   "status": .string("booked")
               ]
               _ = try await client
                   .from("appointments")
                   .insert(vals)
                   .execute()

               // So‘ng fetch qilib yangilash
               await fetchAppointments(for: barberID)
           } catch {
               print("Booking error:", error)
           }
       }

    deinit {
        if let ch = channel {
            Task { await ch.unsubscribe() }
        }
    }
}
