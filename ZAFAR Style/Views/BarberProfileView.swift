import SwiftUI

// MARK: - BarberProfileView
struct BarberProfileView: View {
    @StateObject var vm: BarberProfileViewModel
    let barberID: UUID

    @State private var showBooking = false
    @State private var bookingMessage: String?

    // init to allow injecting an existing ViewModel instance
    init(vm: BarberProfileViewModel, barberID: UUID) {
        _vm = StateObject(wrappedValue: vm)
        self.barberID = barberID
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemGray6), Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if vm.isLoading {
                ProgressView()
            } else if let barber = vm.barber {
                VStack(spacing: 0) {
                    navBar
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            header(barber: barber)

                            HStack(spacing: 32) {
                                BarberStatView(icon: "star.fill",
                                               title: String(format: "%.1f/5", barber.rating ?? 0),
                                               subtitle: "(\(barber.reviews?.count ?? 0))")
                                BarberStatView(icon: "calendar",
                                               title: "\(vm.appointments.count)",
                                               subtitle: "Appointments")
                                BarberStatView(icon: "hand.thumbsup.fill",
                                               title: "\(barber.reviews?.count ?? 0)%",
                                               subtitle: "Recommended")
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                            .padding(.horizontal, 12)

                            if let imgs = barber.gallery, !imgs.isEmpty {
                                gallerySection(images: imgs)
                            }

                            shopInfoSection(barber: barber)

                            if let first = barber.reviews?.first {
                                ReviewPreviewView(review: first)
                                    .padding(.horizontal, 16)
                            }

                            appointmentsSection()

                            Spacer(minLength: 120)
                        }
                        .padding(.top, 8)
                    } // ScrollView

                    // pinned Book Now
                    VStack {
                        Button(action: { showBooking = true }) {
                            Text("Book Now")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                                .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 10)
                    }
                } // VStack
                .sheet(isPresented: $showBooking) {
                    AppointmentTimeSheet(isPresented: $showBooking) { day, time in
                        guard let range = parse(day: day, time: time) else {
                            bookingMessage = "Invalid time selected"
                            return
                        }
                        Task {
                            do {
                                await vm.bookAppointment(barberID: barberID, start: range.start, end: range.end)
                                bookingMessage = "Appointment requested for \(formatted(range.start))"
                            } catch {
                                bookingMessage = "Booking failed: \(error.localizedDescription)"
                                print("Booking error:", error)
                            }
                        }
                    }
                    .presentationDetents([.medium])
                }
                .overlay(bookingToast, alignment: .top)
            } else if let errorMsg = vm.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    Text("Error Loading Barber")
                        .font(.headline)
                    Text(errorMsg)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Retry") {
                        Task {
                            await vm.fetchBarber(id: barberID)
                            await vm.fetchAppointments(for: barberID)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            } else {
                Text("No barber found")
            }
        }
        .task {
            // task modifier ensures this runs when view appears and sets loading state properly
            await vm.fetchBarber(id: barberID)
            await vm.fetchAppointments(for: barberID)
            vm.subscribeToChanges(barberID: barberID)
        }
    }

    // MARK: - Subviews

    private var navBar: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "magnifyingglass")
            }
            Spacer()
            Text("The Sharp Side")
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
            Button(action: {}) {
                Image(systemName: "line.3.horizontal")
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 6)
    }

    private func header(barber: Barber) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Group {
                if let urlString = barber.city, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure:
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFill()
                        @unknown default:
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFill()
                        }
                    }
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: 72, height: 72)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(barber.display_name)
                    .font(.title2)
                    .fontWeight(.bold)
                HStack(spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                    Text(barber.address ?? "")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    Button(action: {
                        // call action
                    }) {
                        Image(systemName: "phone.fill")
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    Button(action: {
                        // chat action
                    }) {
                        Image(systemName: "message")
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
                .padding(.top, 6)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
    }

    private func gallerySection(images: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Photo Gallery").font(.headline)
                Spacer()
                Button(action: {}) {
                    Text("See more").font(.subheadline).foregroundColor(.orange)
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(images, id: \.self) { src in
                        if let url = URL(string: src) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    Color.gray.opacity(0.2)
                                case .success(let image):
                                    image.resizable().scaledToFill()
                                case .failure:
                                    Color.red
                                @unknown default:
                                    Color.gray
                                }
                            }
                            .frame(width: 140, height: 100)
                            .clipped()
                            .cornerRadius(10)
                        } else {
                            Image(src)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 140, height: 100)
                                .clipped()
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func shopInfoSection(barber: Barber) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Barber shop").font(.headline)
            if let shopImg = barber.city {
                Image(shopImg)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 110)
                    .clipped()
                    .cornerRadius(10)
            }
            Text("Service: \(barber.opening_hours ?? "Mon–Sat 9am–10pm")")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Address: \(barber.address ?? "")")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button(action: {}) {
                Text("Show on map")
                    .font(.subheadline)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }

    private func appointmentsSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Appointments").font(.headline).padding(.horizontal, 16)
            ForEach(vm.appointments) { appt in
                AppointmentRow(appt: appt)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color(.systemBackground))
            }
        }
    }

    private var bookingToast: some View {
        Group {
            if let msg = bookingMessage {
                Text(msg)
                    .font(.subheadline)
                    .padding(10)
                    .background(Color.black.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation { bookingMessage = nil }
                        }
                    }
            }
        }
    }

    // MARK: - Helpers

    /// Parse selected day string (Today, Tue, Wed, ...) and time like "11-12" into Date range
    func parse(day: String, time: String) -> (start: Date, end: Date)? {
        let comps = time.split(separator: "-").map { String($0) }
        guard comps.count == 2, let h1 = Int(comps[0]), let h2 = Int(comps[1]) else { return nil }

        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())

        // map day string to offset (0..n). Support "Today" and short names "Tue"/"Wednesday"
        let lower = day.lowercased()
        var offset = 0
        if lower == "today" {
            offset = 0
        } else {
            let names = ["mon","tue","wed","thu","fri","sat","sun"]
            if let idx = names.firstIndex(where: { lower.hasPrefix($0) }) {
                // compute offset relative to weekday of today
                let todayWeekday = calendar.component(.weekday, from: Date()) // 1 = Sun ... 7 = Sat
                // Convert both to 1...7 where Mon = 2 in Calendar default; better compute day numbers
                // Convert names idx (mon=0) to calendar weekday:
                let targetWeekday = ((idx + 2) % 7 == 0) ? 7 : (idx + 2) // mon->2, tue->3, ..., sun->1(handled)
                // find minimal non-negative offset to next targetWeekday
                var diff = targetWeekday - todayWeekday
                if diff < 0 { diff += 7 }
                offset = diff
            } else {
                // fallback: if day looks like short "Tue" and not matched, try numeric suffix (e.g., "Apr 15")
                offset = 0
            }
        }

        guard let start = calendar.date(byAdding: .day, value: offset, to: todayStart),
              let startHour = calendar.date(byAdding: .hour, value: h1, to: start),
              let endHour = calendar.date(byAdding: .hour, value: h2, to: start) else {
            return nil
        }

        return (start: startHour, end: endHour)
    }

    func formatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}

// MARK: - BarberStatView (icon + title + subtitle)
struct BarberStatView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.orange)
                .frame(width: 36, height: 36)
                .background(Color.orange.opacity(0.08))
                .cornerRadius(9)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - AppointmentRow (uses your Appointment model)
struct AppointmentRow: View {
    let appt: Appointment  // assuming Appointment: Identifiable with start_at and end_at: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Start: \(appt.start_at.formatted(.dateTime.month().day().hour().minute()))")
                .font(.subheadline)
            if let end = appt.end_at {
                Text("End: \(end.formatted(.dateTime.hour().minute()))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            if let st = appt.status {
                Text(st.capitalized)
                    .font(.caption2)
                    .padding(6)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(6)
            }
        }
    }
}

// MARK: - ReviewPreviewView (assuming Review model)
struct ReviewPreviewView: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .frame(width: 36, height: 36)
                    .foregroundColor(Color(.systemGray5))
                    .overlay(Text(String(review.userName.prefix(1))).fontWeight(.semibold))
                VStack(alignment: .leading) {
                    HStack {
                        Text(review.userName).fontWeight(.semibold)
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill").foregroundColor(.yellow)
                            Text(String(format: "%.1f", review.rating))
                        }
                    }
                    Text(review.comment)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}


struct AppointmentTimeSheet: View {
    @Binding var isPresented: Bool
    var onBook: (String, String) -> Void

    @State private var selectedDay: String = "Today"
    @State private var selectedTime: String = ""

    let days = ["Today", "Tue", "Wed", "Thu", "Fri"]
    let times = ["9-10", "10-11", "11-12", "12-13", "13-14", "14-15", "15-16"]

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Select Time")
                    .font(.headline)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark").foregroundColor(.gray)
                }
            }
            Text("Pick a time slot that works for you.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(days, id: \.self) { d in
                        Text(d)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(d == selectedDay ? Color.black : Color(.systemGray5))
                            .foregroundColor(d == selectedDay ? .white : .primary)
                            .cornerRadius(10)
                            .onTapGesture { selectedDay = d }
                    }
                }
            }

            let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(times, id: \.self) { t in
                    Text(t)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedTime == t ? Color.black : Color(.systemGray5))
                        .foregroundColor(selectedTime == t ? .white : .primary)
                        .cornerRadius(10)
                        .onTapGesture { selectedTime = t }
                }
            }

            Button(action: {
                onBook(selectedDay, selectedTime)
                isPresented = false
            }) {
                Text("Book Now")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}
