//
//  StatView.swift
//  ZAFAR Style
//
//  Created by Kenjaboy Xajiyev on 26/07/25.
//


import SwiftUI

struct StatView: View {
    var icon: String
    var value: String
    var label: String

    var body: some View {
        VStack {
            Label(value, systemImage: icon)
                .labelStyle(VerticalLabelStyle())
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct VerticalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon
                .foregroundColor(.yellow)
            configuration.title
        }
    }
}
