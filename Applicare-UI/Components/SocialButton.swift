//
//  SocialButton.swift
//  Applicare-UI
//
//  Created by Đình Khoa Nguyễn on 16/3/25.
//
import SwiftUI

struct SocialButton: View {
    var imageName: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(imageName)
                .resizable()
                .frame(width: 30, height: 30)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(Circle())
        }
    }
}

// Provide a default action for preview or when no action is specified
extension SocialButton {
    init(imageName: String) {
        self.imageName = imageName
        self.action = {}
    }
}
