import SwiftUI
import UIKit

struct PhoneLoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    // Telefon raqami formati to'g'riligini tekshirish
    private var isPhoneNumberValid: Bool {
        // Bu yerda siz o'zingizga kerakli validatsiyani kuchaytirishingiz mumkin
        // Hozircha faqat 12 ta belgi ekanligini tekshiramiz.
        viewModel.phoneNumber.count == 12 && viewModel.phoneNumber.allSatisfy { $0.isNumber }
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("📱 Telefon raqamingizni kiriting")
                .font(.title2)
                .fontWeight(.semibold)

            TextField("998901234567", text: $viewModel.phoneNumber)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

            if viewModel.isLoading {
                ProgressView()
                    .padding()
            } else {
                Button("SMS yuborish") {
                    Task {
                        await viewModel.sendSMSCode()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(isPhoneNumberValid ? Color.black : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(!isPhoneNumberValid || viewModel.isLoading)
            }

            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top)
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $viewModel.isCodeSent) {
            // VerifyCodeView endi EnvironmentObject orqali viewModel ni avtomatik oladi
            VerifyCodeView()
        }
    }
}

