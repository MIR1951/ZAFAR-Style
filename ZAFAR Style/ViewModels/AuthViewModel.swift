import Foundation

@MainActor
class AuthViewModel: ObservableObject {
    @Published var phoneNumber = ""
    @Published var verificationCode = ""
    @Published var isCodeSent = false
    @Published var isVerified = false
    @Published var errorMessage = ""

    private var sentCode = ""
    private var accessToken: String?

    func sendSMSCode() async {
        let code = String(Int.random(in: 1000...9999))
        sentCode = code
        print("➡️ SMS kod: \(code)")

        do {
            // 1. Eskiz token olish
            accessToken = try await EskizAPI.getToken()
            guard let token = accessToken else {
                errorMessage = "❌ Token olinmadi"
                return
            }

            // 2. SMS yuborish
            try await EskizAPI.sendSMS(to: phoneNumber, message: "🔐 ZAFAR Style kirish kodingiz: \(code)", token: token)
            isCodeSent = true
            print("✅ Kod yuborildi")
        } catch {
            errorMessage = "❌ Xatolik: \(error.localizedDescription)"
            print(errorMessage)
        }
    }

    func verifyCode() {
        if verificationCode == sentCode {
            isVerified = true
            print("✅ Kod to‘g‘ri!")
        } else {
            isVerified = false
            errorMessage = "❌ Kod noto‘g‘ri!"
        }
    }
}
