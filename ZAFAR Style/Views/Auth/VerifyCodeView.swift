//
//  VerifyCodeView.swift
//  ZAFAR Style
//
//  Created by Kenjaboy Xajiyev on 26/07/25.
//


import SwiftUI

struct VerifyCodeView: View {
  @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("📨 SMS orqali yuborilgan kodni kiriting")
                .font(.headline)
            
            TextField("1234", text: $viewModel.verificationCode)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            Button("Tasdiqlash") {
                viewModel.verifyCode()
            }
            .padding()
            .background(.black)
            .foregroundColor(.white)
            .cornerRadius(8)

           
        }
        .padding()
    }
}
