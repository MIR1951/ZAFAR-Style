//
//  AppointmentTimeModal.swift
//  ZAFAR Style
//
//  Created by Kenjaboy Xajiyev on 26/07/25.
//


import SwiftUI

struct AppointmentTimeModal: View {
    @Binding var isPresented: Bool
    @State private var selectedDate: Date = Date()
    @State private var selectedTime: String = ""

    // Dummy vaqtlar
    let timeSlots = [
        "9 - 10", "10 - 11", "11 - 12", "12 - 13",
        "13 - 14", "14 - 15", "15 - 16", "16 - 17",
        "17 - 18", "18 - 19", "19 - 20", "20 - 21"
    ]

    var body: some View {
        VStack(spacing: 16) {
            // Top bar
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .padding(10)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
                Spacer()
                Text("Appointment Time")
                    .font(.headline)
                Spacer()
                Spacer().frame(width: 32) // balans uchun
            }

            // Description
            Text("Select an appointment time that works best for you.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            // Date Picker Style (faqat kun ko‘rsatiladi)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<7) { offset in
                        let date = Calendar.current.date(byAdding: .day, value: offset, to: Date())!
                        VStack(spacing: 4) {
                            Text(shortDay(date))
                                .font(.subheadline)
                            Text(dateFormatted(date, format: "MMM d"))
                                .font(.headline)
                        }
                        .frame(width: 70, height: 60)
                        .background(selectedDate.isSameDay(as: date) ? Color.black : Color.gray.opacity(0.2))
                        .foregroundColor(selectedDate.isSameDay(as: date) ? .white : .black)
                        .cornerRadius(10)
                        .onTapGesture {
                            selectedDate = date
                        }
                    }
                }
                .padding(.horizontal)
            }

            // Time slots
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 12) {
                ForEach(timeSlots, id: \.self) { slot in
                    Text(slot)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedTime == slot ? Color.black : Color.gray.opacity(0.2))
                        .foregroundColor(selectedTime == slot ? .white : .black)
                        .cornerRadius(8)
                        .onTapGesture {
                            selectedTime = slot
                        }
                }
            }
            .padding(.horizontal)

            // Selected time summary
            if !selectedTime.isEmpty {
                Text("Selected: \(longDate(selectedDate))  •  \(selectedTime)")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }

            // Book Now Button
            Button(action: {
                // keyinchalik supabase ga yozamiz
                print("Booked: \(selectedDate) \(selectedTime)")
                isPresented = false
            }) {
                Text("Book Now")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding(.top)
        .padding(.bottom, 40)
        .background(Color.white)
        .cornerRadius(20)
    }

    // Helpers
    func shortDay(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "EEE"
        return df.string(from: date)
    }

    func longDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "EEEE, MMM d"
        return df.string(from: date)
    }

    func dateFormatted(_ date: Date, format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: date)
    }
}

extension Date {
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }
}
