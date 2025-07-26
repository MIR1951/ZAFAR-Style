import SwiftUI

struct PhoneLoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("📱 Telefon raqamingizni kiriting")
                .font(.title2)

            TextField("998901234567", text: $viewModel.phoneNumber)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)

            Button("SMS yuborish") {
                Task {
                    await viewModel.sendSMSCode()
                }
            }
            .padding()
            .background(.black)
            .foregroundColor(.white)
            .cornerRadius(8)

            // Ko‘rinadigan holatda `VerifyCodeView` ochiladi
            if viewModel.isCodeSent {
                VerifyCodeView(viewModel: _viewModel)
            }

            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

