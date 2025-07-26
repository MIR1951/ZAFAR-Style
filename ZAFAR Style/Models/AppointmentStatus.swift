//
//  AppointmentStatus.swift
//  ZAFAR Style
//
//  Created by Kenjaboy Xajiyev on 26/07/25.
//


import Foundation

// Status uchun enum (optional, lekin tavsiya qilinadi)
enum AppointmentStatus: String, Codable {
    case pending
    case approved
    case rejected
}

struct Appointment: Identifiable, Codable, Hashable {
    var id: Int
    var name: String
    var phone: String
    var appointmentTime: Date
    var status: String
    var userId: UUID

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case phone
        case appointmentTime = "appointment_time"
        case status
        case userId = "user_id"
    }
}
