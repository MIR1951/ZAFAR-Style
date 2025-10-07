//
//  AppointmentStatus.swift
//  ZAFAR Style
//
//  Created by Kenjaboy Xajiyev on 26/07/25.
//


import Foundation



struct Appointment: Identifiable, Decodable {
    let id: UUID
    let barber_id: UUID
    let user_id: UUID
    let start_at: Date
    let end_at: Date?        // tugash vaqti
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case barber_id
        case user_id
        case start_at
        case end_at
        case status
    }
}

struct Barber: Identifiable, Decodable {
    let id: UUID
    let display_name: String
    let city: String?
    let rating: Double?
    let reviews:[Review]?
    let address: String?
    let opening_hours: String?
    let gallery: [String]?   // jsonb array of strings
    let created_at: Date?     // optional, agar kerak bo‘lsa

    enum CodingKeys: String, CodingKey {
        case id
        case display_name
        case city
        case rating
        case reviews
        case address
        case opening_hours
        case gallery
        case created_at
    }
}

struct Review: Identifiable, Decodable {
    let id: UUID
    let userName: String
    let rating: Double
    let comment: String
}


