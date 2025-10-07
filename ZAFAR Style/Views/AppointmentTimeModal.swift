import SwiftUI

struct AppointmentsListView: View {
    @StateObject private var viewModel = BarberProfileViewModel( supabaseURL: "https://hidfracwzkmgicfcttbw.supabase.co", supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhpZGZyYWN3emttZ2ljZmN0dGJ3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM1NDUxMDcsImV4cCI6MjA2OTEyMTEwN30.mFQsmuvDnlGqv89Trdo4RiZ4XkyjJKJrbCGnU9WTnKk")

    let barberID: UUID

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Yuklanmoqda...")
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else if viewModel.appointments.isEmpty {
                Text("Hozircha bo‘sh vaqtlar yo‘q")
                    .foregroundColor(.secondary)
            } else {
                List(viewModel.appointments) { appointment in
                    VStack(alignment: .leading) {
                        Text(appointment.start_at.formatted(date: .omitted, time: .shortened))
                            .font(.headline)
                        Text("Holati: \(appointment.status)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .task {
            await viewModel.fetchAppointments(for: barberID)
        }
        .navigationTitle("Available Times")
    }
}
extension Date {
    func formatted(date: Date.FormatStyle.DateStyle, time: Date.FormatStyle.TimeStyle) -> String {
        self.formatted(Date.FormatStyle(date: date, time: time))
    }
}
