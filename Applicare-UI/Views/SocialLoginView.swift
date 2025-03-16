//
//  SocialLoginView.swift
//  Applicare-UI
//
//  Created by Đình Khoa Nguyễn on 16/3/25.
//


import SwiftUI

struct SocialLoginView: View {
    var body: some View {
        VStack {
            Text("or")
                .foregroundColor(.gray)
                .padding(.vertical, 10)
            
            HStack(spacing: 20) {
                SocialButton(imageName: "Google")
                SocialButton(imageName: "Apple")
                SocialButton(imageName: "Facebook")
            }
        }
        .padding(.top, 20)
    }
}

