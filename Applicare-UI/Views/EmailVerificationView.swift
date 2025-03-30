//
//  EmailVerificationView.swift
//  Applicare-UI
//
//  Created by Applicare on 16/3/25.
//

import SwiftUI

struct EmailVerificationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var verificationToken: String = ""
    @Binding var showSignIn: Bool
    
    var body: some View {
        VStack {
            LogoView()
            
            Text("Verify Your Email")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            VStack(alignment: .center, spacing: 16) {
                Text("We've sent a verification link to:")
                    .font(.subheadline)
                
                Text(authViewModel.emailForVerification)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Please check your email and click the link, or enter the verification token below.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.vertical)
            }
            .padding(.horizontal, 32)
            .padding(.top, 20)
            
            CustomTextField(placeholder: "Verification Token", imageName: "key", text: $verificationToken)
                .padding(.horizontal, 32)
            
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 5)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button(action: {
                authViewModel.verifyEmail(token: verificationToken)
            }) {
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Verify Email")
                        .font(.headline)
                        .fontWeight(.semibold)
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
            .disabled(verificationToken.isEmpty || authViewModel.isLoading)
            
            Button(action: {
                authViewModel.resendVerificationEmail()
            }) {
                Text("Resend Verification Email")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .padding(.top, 16)
            .disabled(authViewModel.isLoading)
            
            Spacer()
            
            HStack {
                Text("Return to")
                Button(action: {
                    showSignIn = false
                }) {
                    Text("Sign In")
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
    EmailVerificationView(showSignIn: .constant(true))
        .environmentObject(AuthViewModel())
} 