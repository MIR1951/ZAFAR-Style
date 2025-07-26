import SwiftUI

struct BarberProfileView: View {
    @State private var showModal = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // MARK: - Profile Header
                    HStack {
                        Image("barber_avatar") // Assets-ga profil rasmi qo‘shing
                            .resizable()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Nate black")
                                .font(.headline)
                            Text("📍 Atlanta")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        HStack(spacing: 16) {
                            Image(systemName: "phone.fill")
                            Image(systemName: "bubble.right.fill")
                        }
                        .foregroundColor(.black)
                    }

                    // MARK: - Stats Row
                    HStack(spacing: 24) {
                        StatView(icon: "star.fill", value: "4.6/5", label: "1123")
                        StatView(icon: "hand.thumbsup.fill", value: "46%", label: "Recommended")
                        StatView(icon: "calendar", value: "232", label: "Appointment")
                    }

                    Divider()

                    // MARK: - Photo Gallery
                    HStack {
                        Text("Photo Gallery")
                            .font(.headline)
                        Spacer()
                        Button("See more") {
                            // Action
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(1..<5) { i in
                                Image("cut\(i)") // Assets: cut1, cut2, ...
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                            }
                        }
                    }

                    // MARK: - Barber Shop Info
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Barber shop")
                            .font(.headline)
                        Text("Service: Mon to Sat - 9am to 10pm")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("Address: 1201 Peachtree St NE, Atlanta GA 30309")
                            .font(.subheadline)
                        Button("Show on map") {}
                            .font(.footnote)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(6)
                    }

                    // MARK: - Reviews
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Reviews")
                                .font(.headline)
                            Spacer()
                            Button("See all") {}
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("David")
                                .font(.subheadline)
                            Spacer()
                            Label("5/5", systemImage: "star.fill")
                                .font(.footnote)
                                .foregroundColor(.yellow)
                            Text("Excellent")
                                .font(.footnote)
                        }
                    }
                }
                .padding()
            }

            // MARK: - Book Now Button
            
            Button(action: {
                showModal = true
            }) {
                Text("Book Now")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding(.bottom, 8)
            .sheet(isPresented: $showModal) {
                AppointmentTimeModal(isPresented: $showModal)
            }

        }
    }
}

#Preview {
    BarberProfileView()
}
