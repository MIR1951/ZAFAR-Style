//
//  TimeSlot.swift
//  ZAFAR Style
//
//  Created by Kenjaboy Xajiyev on 26/07/25.
//


import Foundation

struct TimeSlot: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let isBooked: Bool

    var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a" // Masalan: 9:00 AM, 1:30 PM
        return formatter.string(from: date)
    }
}
