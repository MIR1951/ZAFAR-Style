import Foundation

struct EskizAPI {
    static let email = "kenjabek347@gmail.com" // <- o'zingizning Eskiz email
    static let password = "tWTF8IwHzumeRiJ2txEWTfDxLguHhTwipsvt76Hj"     // <- o'zingizning Eskiz parol

    // 1. Login va token olish
    static func getToken() async throws -> String {
        guard let url = URL(string: "https://notify.eskiz.uz/api/auth/login") else {
            throw URLError(.badURL)
        }

        let body = [
            "email": email,
            "password": password
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, _) = try await URLSession.shared.data(for: request)
        let result = try JSONDecoder().decode(EskizTokenResponse.self, from: data)

        print("✅ Token olindi: \(result.data.token)")
        return result.data.token
    }

    // 2. SMS yuborish
    static func sendSMS(to phoneNumber: String, message: String, token: String) async throws {
        guard let url = URL(string: "https://notify.eskiz.uz/api/message/sms/send") else {
            throw URLError(.badURL)
        }

        let body = [
            "mobile_phone": phoneNumber,
            "message": message,
            "from": "4546"
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, _) = try await URLSession.shared.data(for: request)
        print("📩 Eskiz javobi: \(String(data: data, encoding: .utf8) ?? "No Data")")
    }
}

// MARK: - Eskiz javobi struct
struct EskizTokenResponse: Decodable {
    let message: String
    let data: TokenData

    struct TokenData: Decodable {
        let token: String
    }
}
