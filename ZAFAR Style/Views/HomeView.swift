//
//  HomeView.swift
//  ZAFAR Style
//
//  Created by Kenjaboy Xajiyev on 13/08/25.
//


import SwiftUI

struct HomeView: View {
    @State private var showBookingSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                // Profil rasmi
                Image("barber_profile")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 250)
                    .clipped()
                
                // Ism va joylashuv
                VStack(spacing: 4) {
                    Text("Nate Black")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Tashkent, Uzbekistan")
                        .foregroundColor(.secondary)
                }
                
                // Ijtimoiy tarmoqlar
                HStack(spacing: 20) {
                    Link(destination: URL(string: "https://instagram.com")!) {
                        Image(systemName: "camera")
                    }
                    Link(destination: URL(string: "https://facebook.com")!) {
                        Image(systemName: "f.circle")
                    }
                }
                .font(.title2)
                .padding(.top, 8)
                
                // Baholar
                HStack {
                    ForEach(0..<5) { _ in
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                    Text("4.8")
                        .font(.headline)
                        .padding(.leading, 4)
                }
                
                // Photo gallery
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(1..<5) { index in
                            Image("gallery_\(index)")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipped()
                                .cornerRadius(10)
                        }
                    }
                }
                
                // Manzil
                VStack(alignment: .leading, spacing: 4) {
                    Text("Address")
                        .font(.headline)
                    Text("123 Main Street, Tashkent")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Book Now tugmasi
                Button(action: {
                    showBookingSheet.toggle()
                }) {
                    Text("Book Now")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(12)
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .sheet(isPresented: $showBookingSheet) {
            BookingView()
        }
    }
}

#Preview {
    HomeView()
}
