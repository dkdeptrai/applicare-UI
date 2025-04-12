//
//  SignUpView.swift
//  Applicare-UI
//
//  Created by Đình Khoa Nguyễn on 16/3/25.
//

import SwiftUI

struct SignUpView: View {
  @EnvironmentObject var authViewModel: AuthViewModel
  @State private var name: String = ""
  @State private var email: String = ""
  @State private var password: String = ""
  @State private var confirmPassword: String = ""
  @State private var agreeToTerms = false
  @Binding var showSignIn: Bool
  
  var body: some View {
    VStack {
      LogoView()
      Text("Sign Up")
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding(.top, 20)
      
      VStack(spacing: 16) {
        CustomTextField(placeholder: "Name", imageName: "person", text: $name)
          .textContentType(.name)
          .autocapitalization(.words)
        
        CustomTextField(placeholder: "Email", imageName: "envelope", text: $email)
          .keyboardType(.emailAddress)
          .autocapitalization(.none)
          .autocorrectionDisabled(true)
          .textContentType(.emailAddress)
        
        CustomTextField(placeholder: "Password", imageName: "lock", isSecure: true, text: $password)
          .textContentType(.newPassword)
          .autocapitalization(.none)
          .autocorrectionDisabled(true)
          .disableAutocorrection(true)
        
        CustomTextField(placeholder: "Confirm password", imageName: "lock", isSecure: true, text: $confirmPassword)
          .textContentType(.newPassword)
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
      
      Button(action: {
        authViewModel.signUp(name: name, email: email, password: password, confirmPassword: confirmPassword)
      }) {
        if authViewModel.isLoading {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
        } else {
          Text("Sign up")
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
        }
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(Color.blue)
      .cornerRadius(10)
      .padding(.horizontal, 32)
      .padding(.top, 20)
      .disabled(!agreeToTerms || name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || password != confirmPassword || authViewModel.isLoading)
      
      SocialLoginView()
      
      Spacer()
      
      HStack {
        Text("Already have an account?")
        Button(action: {
          showSignIn = false
        }) {
          Text("Sign in")
            .fontWeight(.semibold)
            .foregroundColor(.blue)
        }
      }
      .font(.footnote)
      .padding(.bottom, 20)
    }
  }
}

// Preview with a default constant binding for showSignIn
#Preview {
  SignUpView(showSignIn: .constant(true))
    .environmentObject(AuthViewModel())
}
