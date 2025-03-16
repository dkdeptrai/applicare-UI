//
//  SignUpView.swift
//  Applicare-UI
//
//  Created by Đình Khoa Nguyễn on 16/3/25.
//

import SwiftUI

struct SignUpView: View {
  @State private var agreeToTerms = false
  
  var body: some View {
    VStack {
      LogoView()
      Text("Sign Up")
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding(.top, 20)
      
      VStack(spacing: 16) {
        CustomTextField(placeholder: "Email", imageName: "envelope")
        CustomTextField(placeholder: "Password", imageName: "lock", isSecure: true)
        CustomTextField(placeholder: "Confirm password", imageName: "lock", isSecure: true)
      }
      .padding(.horizontal, 32)
      .padding(.top, 20)
      
      HStack {
        Toggle(isOn: $agreeToTerms) {
          Text("Agree with")
          Button(action: {}) {
            Text("Terms and Privacy")
              .foregroundColor(.blue)
          }
        }
        .toggleStyle(CheckboxToggleStyle())
      }
      .padding(.horizontal, 32)
      
      Button(action: {}) {
        Text("Sign up")
          .font(.headline)
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
        Text("Already have an account?")
        Button(action: {}) {
          Text("Sign in")
            .foregroundColor(.blue)
        }
      }
      .font(.footnote)
      .padding(.bottom, 20)
    }
  }
}

#Preview {
  SignUpView()
}
