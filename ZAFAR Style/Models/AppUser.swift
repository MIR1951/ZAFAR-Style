import Foundation

// Bu model Supabase'dagi 'users' jadvalining tuzilishiga mos kelishi kerak.
struct AppUser: Codable, Identifiable {
    let id: Int
    let createdAt: Date
    let phone: String

    // JSON'dagi 'created_at' (snake_case) ni Swift'dagi 'createdAt' (camelCase) ga o'girish uchun ishlatiladi.
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case phone
    }
}
