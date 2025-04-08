//
//  SignInView.swift
//  Applicare-UI
//
//  Created by Đình Khoa Nguyễn on 16/3/25.
//

import SwiftUI

struct SignInView: View {
  @EnvironmentObject var authViewModel: AuthViewModel
  @State private var email: String = ""
  @State private var password: String = ""
  @Binding var showSignUp: Bool
  
  var body: some View {
    VStack {
      LogoView()
      Text("Sign In")
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding(.top, 20)
      
      VStack(spacing: 16) {
        CustomTextField(placeholder: "Email", imageName: "envelope", isSecure: false, text: $email)
          .keyboardType(.emailAddress)
          .autocapitalization(.none)
          .autocorrectionDisabled(true)
          .textContentType(.emailAddress)
        
        CustomTextField(placeholder: "Password", imageName: "lock", isSecure: true, text: $password)
          .textContentType(.password)
          .autocapitalization(.none)
          .autocorrectionDisabled(true)
          .disableAutocorrection(true)
      }
      .padding(.horizontal, 32)
      .padding(.top, 20)
      
      if let errorMessage = authViewModel.errorMessage {
        Text(errorMessage)
          .foregroundColor(.red)
          .font(.caption)
          .padding(.top, 5)
      }
      
      HStack {
        Spacer()
        Button(action: {}) {
          Text("Forgot Password?")
            .font(.footnote)
            .foregroundColor(.blue)
        }
      }
      .padding(.horizontal, 32)
      
      Button(action: {
        authViewModel.login(email: email, password: password)
      }) {
        if authViewModel.isLoading {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
        } else {
          Text("Sign In")
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
        }
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(Color.blue)
      .cornerRadius(10)
      .padding(.horizontal, 32)
      .padding(.top, 20)
      .disabled(authViewModel.isLoading)
      
      SocialLoginView()
      
      Spacer()
      
      HStack {
        Text("Don't have an account?")
        Button(action: {
          showSignUp = true
        }) {
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
  SignInView(showSignUp: .constant(false))
    .environmentObject(AuthViewModel())
}
