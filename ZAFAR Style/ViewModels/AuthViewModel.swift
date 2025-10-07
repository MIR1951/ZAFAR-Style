import Foundation
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var phoneNumber = ""
    @Published var verificationCode = ""
    @Published var isCodeSent = false
    @Published var isVerified = false
    @Published var errorMessage = ""
    @Published var isLoading = false

    // MARK: - Private Properties
    private var sentCode = ""
    private var accessToken: String?

    // MARK: - Supabase Client
    // Kalitlar xavfsiz tarzda alohida fayldan olinmoqda.
        private let supabase = SupabaseClient(
        supabaseURL: SupabaseCredentials.url,
        supabaseKey: SupabaseCredentials.apiKey
    )

    init() {
        checkSession()
    }

    // MARK: - Public Methods
        func sendSMSCode() async {
        // So'rov boshlanishidan oldin yuklanish holatini yoqamiz
        isLoading = true
        // Eski xatoliklarni tozalaymiz
        errorMessage = ""

        let code = String(Int.random(in: 1000...9999))
        sentCode = code
        
        // DIQQAT: Kod faqat DEBUG rejimida konsolga chiqariladi.
        #if DEBUG
        print("➡️ SMS kod: \(code)")
        #endif

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
        // So'rov tugagach, natijadan qat'iy nazar, yuklanish holatini o'chiramiz
        isLoading = false
    }

    func signOut() async {
        do {
            try await supabase.auth.signOut()
            self.isVerified = false
            print("✅ Foydalanuvchi tizimdan chiqdi.")
        } catch {
            print("❌ Chiqishda xatolik: \(error.localizedDescription)")
        }
    }

    func verifyCode() {
                if verificationCode == sentCode {
            isVerified = true
            isCodeSent = false // Bu o'zgarish sheet'ni avtomatik yopadi
            print("✅ Kod to‘g‘ri!")
            Task {
                await saveUserToSupabase(phone: phoneNumber)
            }
        } else {
            isVerified = false
            errorMessage = "❌ Kod noto‘g‘ri!"
        }
    }
    
    // MARK: - Private Supabase Methods
        private func checkSession() {
        Task {
            do {
                let session = try await supabase.auth.session
                // Sessiya mavjud bo'lsa, foydalanuvchi tizimga kirgan hisoblanadi
                self.isVerified = true
                print("✅ Mavjud sessiya topildi.")
            } catch {
                // Sessiya yo'q bo'lsa, hech narsa qilmaymiz, isVerified false bo'lib qoladi
                print("ℹ️ Mavjud sessiya topilmadi.")
            }
        }
    }

    private func saveUserToSupabase(phone: String) async {
        do {
            // Foydalanuvchi mavjudligini tekshirish
            // --- DEBUG: Print raw server response ---
        let response = try await supabase.database
            .from("users")
            .select()
            .eq("phone", value: phone)
            .execute()

        // Sanani to'g'ri formatda o'qish uchun maxsus dekoder yaratamiz
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        // Ma'lumotni AppUser modeliga o'giramiz
        let users = try decoder.decode([AppUser].self, from: response.data)

            // Agar foydalanuvchi topilmasa, yangisini qo'shish
            if users.isEmpty {
                // `created_at` maydonini Supabase o'zi to'ldirishi kerak (default value = now())
                try await supabase.database
                    .from("users")
                    .insert(["phone": phone])
                    .execute()
                print("✅ Yangi foydalanuvchi Supabasega yozildi")
            } else {
                print("ℹ️ Bu telefon raqam allaqachon ro‘yxatda bor")
            }
        } catch {
            // Xatolikni `errorMessage` ga yozish foydalanuvchiga ko'rsatish uchun yaxshiroq bo'lishi mumkin
            print("❌ Supabase yozuv xatoligi: \(error.localizedDescription)")
        }
    }
}
