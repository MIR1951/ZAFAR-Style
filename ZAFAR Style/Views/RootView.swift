//
//  RootView.swift
//  ZAFAR Style
//
//  Created by Kenjaboy Xajiyev on 26/07/25.
//


import SwiftUI

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        if authVM.isVerified {
            BarberProfileView() // bu sizning asosiy sahifangiz bo‘ladi
        } else {
            PhoneLoginView()
        }
    }
}
