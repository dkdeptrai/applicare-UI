//
//  SocialButton.swift
//  Applicare-UI
//
//  Created by Đình Khoa Nguyễn on 16/3/25.
//
import SwiftUI

struct SocialButton: View {
    var imageName: String
    
    var body: some View {
        Button(action: {}) {
            Image(imageName)
                .resizable()
                .frame(width: 30, height: 30)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(Circle())
        }
    }
}
