//
//  VerifyCodeView.swift
//  ZAFAR Style
//
//  Created by Kenjaboy Xajiyev on 26/07/25.
//


import SwiftUI
import UIKit

struct VerifyCodeView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    private var isCodeValid: Bool {
        viewModel.verificationCode.count == 4 && viewModel.verificationCode.allSatisfy { $0.isNumber }
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("📨 SMS orqali yuborilgan kodni kiriting")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            TextField("1234", text: $viewModel.verificationCode)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .multilineTextAlignment(.center)
                .font(.title2)

            Button("Tasdiqlash") {
                viewModel.verifyCode()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(isCodeValid ? Color.black : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(!isCodeValid)

            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .padding(.top)
            }
            
            Spacer()
        }
        .padding()
        // Foydalanuvchi oynani pastga surib yopishni boshlaganda, eski xatolikni tozalash
        .onDisappear {
            viewModel.errorMessage = ""
        }
    }
}
