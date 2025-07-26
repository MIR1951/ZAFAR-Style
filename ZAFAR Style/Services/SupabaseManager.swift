//
//  SupabaseManager.swift
//  ZAFAR Style
//
//  Created by Kenjaboy Xajiyev on 26/07/25.
//


import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient

    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://czbbwxzwmugvvvjastvy.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN6YmJ3eHp3bXVndnZ2amFzdHZ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM1MDgxNDAsImV4cCI6MjA2OTA4NDE0MH0.zr_VgGhKVbx4d7ADGpinAf8EK5s2iz0gOSFplWjsl8g"
        )
    }
}
