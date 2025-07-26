import Foundation

class SMSManager {
    static var accessToken: String?

    /// Eskiz.uz token olish
    static func fetchToken(completion: @escaping (Bool) -> Void) {
        let url = URL(string: "https://notify.eskiz.uz/api/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters = [
            "email": "kenjabek347@gmail.com",
            "password": "tWTF8IwHzumeRiJ2txEWTfDxLguHhTwipsvt76Hj"
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else {
                print("❌ Javob yo‘q (no data)")
                completion(false)
                return
            }

            // 🧪 Debug javob
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📩 Eskiz javobi: \(jsonString)")
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

                if let dataDict = json?["data"] as? [String: Any],
                   let token = dataDict["token"] as? String {
                    self.accessToken = token
                    print("✅ Token olindi: \(token)")
                    completion(true)
                } else {
                    print("❌ Token topilmadi. Javob: \(json ?? [:])")
                    completion(false)
                }
            } catch {
                print("❌ Token decoding error: \(error)")
                completion(false)
            }
        }.resume()
    }


    /// SMS yuborish
    static func sendSMS(to phone: String, message: String, completion: @escaping (Bool) -> Void) {
        guard let token = accessToken else {
            print("❌ Access token yo‘q. Avval `fetchToken()` chaqiring.")
            completion(false)
            return
        }

        guard let url = URL(string: "https://notify.eskiz.uz/api/message/sms/send") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = [
            "mobile_phone": phone,       // Masalan: 998901234567
            "message": message,          // Kod yoki habar
            "from": "4546"               // Eskiz’dan berilgan short code (odatda 4546)
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print("❌ SMS error:", error)
                completion(false)
                return
            }

            completion(true)
        }.resume()
    }
}

struct TokenResponse: Codable {
    let data: TokenData
}

struct TokenData: Codable {
    let token: String
}
