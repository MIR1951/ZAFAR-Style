//
//  ZAFAR_StyleApp.swift
//  ZAFAR Style
//
//  Created by Kenjaboy Xajiyev on 26/07/25.
//

import SwiftUI

@main
struct ZAFAR_StyleApp: App {
    @StateObject private var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            BarberProfileView(vm: BarberProfileViewModel(
                supabaseURL: "https://hidfracwzkmgicfcttbw.supabase.co", supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhpZGZyYWN3emttZ2ljZmN0dGJ3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM1NDUxMDcsImV4cCI6MjA2OTEyMTEwN30.mFQsmuvDnlGqv89Trdo4RiZ4XkyjJKJrbCGnU9WTnKk"
            ), barberID: UUID(uuidString: "b9b78e35-1944-4746-b7f8-fdd02bd5506c")!
                              )
        }
    }
}


