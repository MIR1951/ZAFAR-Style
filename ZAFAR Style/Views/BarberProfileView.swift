import SwiftUI

struct BarberProfileView: View {
    @StateObject var vm: BarberProfileViewModel
    let barberID: UUID

    @State private var showBooking = false

    var body: some View {
        VStack {
            if vm.isLoading {
                ProgressView()
            } else if let barber = vm.barber {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        BarberHeaderView(barber: barber)
                        if let imgs = barber.gallery {
                            PhotoGalleryView(images: imgs)
                        }
                        ShopInfoView(workingHours: barber.opening_hours ?? "",
                                     address: barber.address ?? "")
                        if let revs = barber.reviews, let first = revs.first {
                            ReviewPreviewView(review: first)
                        }
                        Button(action: {
                            showBooking = true
                        }) {
                            Text("Book Now")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        VStack(alignment: .leading) {
                            Text("Appointments")
                                .font(.title3)
                                .padding(.vertical, 8)
                            ForEach(vm.appointments) { appt in
                                AppointmentRow(appt: appt)
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle(barber.display_name)
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $showBooking) {
                    AppointmentTimeSheet(isPresented: $showBooking) { day, time in
                        if let dateRange = parse(day: day, time: time) {
                            Task {
                                try? await vm.bookAppointment(barberID: barberID,
                                                              start: dateRange.start,
                                                              end: dateRange.end)
                            }
                        }
                    }
                    .presentationDetents([.height(420)])
                }
            } else {
                Text("No barber found")
            }
        }
        .onAppear {
            Task {
                await vm.fetchBarber(id: barberID)
                await vm.fetchAppointments(for: barberID)
                vm.subscribeToChanges(barberID: barberID)
            }
        }
    }

    func parse(day: String, time: String) -> (start: Date, end: Date)? {
        let comps = time.split(separator: "-")
        guard comps.count == 2,
              let h1 = Int(comps[0]),
              let h2 = Int(comps[1]) else {
            return nil
        }
        let today = Date()
        var base = Calendar.current.startOfDay(for: today)
        if day != "Today" {
            // qo‘shimcha kun logikasi
        }
        let start = Calendar.current.date(byAdding: .hour, value: h1, to: base)!
        let end = Calendar.current.date(byAdding: .hour, value: h2, to: base)!
        return (start, end)
    }
}



// Komponentlar:
struct BarberHeaderView: View {
    let barber: Barber

    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 64, height: 64)
                .foregroundColor(.gray)
            VStack(alignment: .leading, spacing: 4) {
                Text(barber.display_name)
                    .font(.title2)
                    .fontWeight(.bold)
                if let rating = barber.rating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill").foregroundColor(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(.subheadline)
                    }
                }
                if let addr = barber.address {
                    Text(addr)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
    }
}

struct PhotoGalleryView: View {
    let images: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(images, id: \.self) { img in
                    // Agar URL bo‘lsa, AsyncImage; agar lokal asset bo‘lsa Image(...)
                    AsyncImage(url: URL(string: img)) { phase in
                        switch phase {
                        case .empty:
                            Color.gray.opacity(0.3)
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Color.red
                        @unknown default:
                            Color.gray
                        }
                    }
                    .frame(width: 120, height: 100)
                    .clipped()
                    .cornerRadius(8)
                }
            }
        }
    }
}

struct ShopInfoView: View {
    let workingHours: String
    let address: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "clock")
                Text("Hours: \(workingHours)")
            }
            HStack {
                Image(systemName: "map")
                Text(address)
            }
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
}

struct ReviewPreviewView: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(review.userName).fontWeight(.semibold)
                Spacer()
                HStack(spacing: 2) {
                    Image(systemName: "star.fill").foregroundColor(.yellow)
                    Text(String(format: "%.1f", review.rating))
                }
            }
            Text(review.comment)
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

struct AppointmentRow: View {
    let appt: Appointment

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Start: \(appt.start_at.formatted(.dateTime.hour().minute()))")
            if let e = appt.end_at {
                Text("End: \(e.formatted(.dateTime.hour().minute()))")
            }
            if let st = appt.status {
                Text(st.capitalized)
                    .font(.caption)
                    .padding(4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)
            }
        }
        .padding(.vertical, 8)
    }
}

