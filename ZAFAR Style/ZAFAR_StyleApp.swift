//
//  ZAFAR_StyleApp.swift
//  ZAFAR Style
//
//  Created by Kenjaboy Xajiyev on 26/07/25.
//

import SwiftUI

@main
struct ZAFAR_StyleApp: App {
    @StateObject var authVM = AuthViewModel()

       var body: some Scene {
           WindowGroup {
               if authVM.isVerified {
                  BarberProfileView()
                       .environmentObject(authVM)// Bu sizning asosiy sahifangiz bo'lishi kerak
               } else {
                   PhoneLoginView()
                       .environmentObject(authVM)
               }
           }
       }
}
