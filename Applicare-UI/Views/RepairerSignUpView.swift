import SwiftUI

struct RepairerSignUpView: View {
    @EnvironmentObject var repairerAuthViewModel: RepairerAuthViewModel
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var agreeToTerms = false
    @State private var validationMessage: String? = nil
    @Binding var showSignIn: Bool
    
    var body: some View {
        VStack {
            LogoView()
            Text("Repairer Sign Up")
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
            
            if let message = validationMessage {
                Text(message)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal, 32)
                    .padding(.top, 5)
            } else if let errorMessage = repairerAuthViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(errorMessage == "Registration successful! Please sign in." ? .green : .red)
                    .font(.caption)
                    .padding(.horizontal, 32)
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
            .padding(.top, 10)
            
            Button(action: performSignUp) {
                if repairerAuthViewModel.isLoading {
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
            .disabled(repairerAuthViewModel.isLoading)
            
            Spacer()
            
            HStack {
                Text("Already have an account?")
                Button(action: {
                    repairerAuthViewModel.errorMessage = nil
                    validationMessage = nil
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
    
    func performSignUp() {
        validationMessage = nil
        repairerAuthViewModel.errorMessage = nil
        
        if name.isEmpty && email.isEmpty && password.isEmpty {
            validationMessage = "Please fill in all required fields."
            return
        } else if name.isEmpty {
            validationMessage = "Please enter your name."
            return
        } else if email.isEmpty {
            validationMessage = "Please enter your email."
            return
        } else if !isValidEmail(email) {
            validationMessage = "Please enter a valid email address."
            return
        } else if password.isEmpty {
            validationMessage = "Please enter a password."
            return
        } else if confirmPassword.isEmpty {
            validationMessage = "Please confirm your password."
            return
        } else if password != confirmPassword {
            validationMessage = "Passwords do not match."
            return
        } else if !agreeToTerms {
            validationMessage = "You must agree to the terms and privacy policy."
            return
        } else if password.count < 6 {
            validationMessage = "Password must be at least 6 characters."
            return
        }
        
        repairerAuthViewModel.signUp(name: name, email: email, password: password, confirmPassword: confirmPassword)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if repairerAuthViewModel.errorMessage == "Registration successful! Please sign in." {
                showSignIn = false
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

#Preview {
    RepairerSignUpView(showSignIn: .constant(true))
        .environmentObject(RepairerAuthViewModel())
} 