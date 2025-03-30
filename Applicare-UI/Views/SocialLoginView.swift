//
//  SocialLoginView.swift
//  Applicare-UI
//
//  Created by Đình Khoa Nguyễn on 16/3/25.
//


import SwiftUI

struct SocialLoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack {
            Text("or")
                .foregroundColor(.gray)
                .padding(.vertical, 10)
            
            HStack(spacing: 20) {
                SocialButton(imageName: "Google", action: {
                    // Handle Google sign in
                    print("Google sign in tapped")
                })
                
                SocialButton(imageName: "Apple", action: {
                    // Handle Apple sign in
                    print("Apple sign in tapped")
                })
                
                SocialButton(imageName: "Facebook", action: {
                    // Handle Facebook sign in
                    print("Facebook sign in tapped")
                })
            }
        }
        .padding(.top, 20)
    }
}

#Preview {
    SocialLoginView()
        .environmentObject(AuthViewModel())
}

