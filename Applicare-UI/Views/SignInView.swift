//
//  SignInView.swift
//  Applicare-UI
//
//  Created by Đình Khoa Nguyễn on 16/3/25.
//

import SwiftUI

struct SignInView: View {
  var body: some View {
    VStack {
      LogoView()
      Text("Sign In")
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding(.top, 20)
      
      VStack(spacing: 16) {
        CustomTextField(placeholder: "Email", imageName: "envelope")
        CustomTextField(placeholder: "Password", imageName: "lock", isSecure: true)
      }
      .padding(.horizontal, 32)
      .padding(.top, 20)
      
      
      HStack {
        Spacer()
        Button(action: {}) {
          Text("Forgot Password?")
            .font(.footnote)
            .foregroundColor(.blue)
        }
      }
      .padding(.horizontal, 32)
      
      Button(action: {}) {
        Text("Sign In")
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.blue)
          .cornerRadius(10)
      }
      .padding(.horizontal, 32)
      .padding(.top, 20)
      
      SocialLoginView()
      
      Spacer()
      
      HStack {
        Text("Don't have an account?")
        Button(action: {}) {
          Text("Sign Up")
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.blue)
        }
      }
      .font(.footnote)
      .padding(.bottom, 20)
    }
  }
}

#Preview {
  SignInView()
}
