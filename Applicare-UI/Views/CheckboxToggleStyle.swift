//
//  CheckboxToggleStyle.swift
//  Applicare-UI
//
//  Created by Đình Khoa Nguyễn on 16/3/25.
//


import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                .onTapGesture { configuration.isOn.toggle() }
            configuration.label
        }
    }
}
