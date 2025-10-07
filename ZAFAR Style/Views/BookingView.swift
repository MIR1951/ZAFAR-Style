//
//  BookingView.swift
//  ZAFAR Style
//
//  Created by Kenjaboy Xajiyev on 13/08/25.
//


import SwiftUI

struct BookingView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Select a time slot")
                    .font(.title2)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Book Appointment")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    BookingView()
}
