//
//  OnboardingView.swift
//  Applicare-UI
//

import SwiftUI
import Lottie

struct OnboardingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var currentStep = 0
    @State private var name: String = ""
    @State private var dateOfBirth: String = "DD/M/YY"
    @State private var phoneNumber: String = ""
    @State private var address: String = ""
    @State private var showDatePicker: Bool = false
    @State private var selectedDate: Date = Date()
    @State private var isSubmitting: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var validationMessage: String? = nil
    
    // Onboarding steps content
    private let onboardingSteps = [
        OnboardingStep(
            title: "Welcome to Applicare",
            description: "Your one-stop solution for finding and booking professional repair services.",
            animationName: "Repair"
        ),
        OnboardingStep(
            title: "Find Nearby Repairers",
            description: "Discover skilled repair professionals in your area with just a few taps.",
            animationName: "Electrician"
        ),
        OnboardingStep(
            title: "Book Appointments",
            description: "Schedule repair services at your convenience, right from your phone.",
            animationName: "Plumber"
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                if currentStep < onboardingSteps.count {
                    // Intro onboarding steps
                    OnboardingIntroView(
                        step: onboardingSteps[currentStep],
                        currentStep: currentStep,
                        totalSteps: onboardingSteps.count,
                        onNext: {
                            withAnimation {
                                currentStep += 1
                            }
                        },
                        onSkip: {
                            withAnimation {
                                currentStep = onboardingSteps.count
                            }
                        }
                    )
                } else {
                    // Profile information collection (final step)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Header
                            Text("Complete your information")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.top, 20)
                            
                            // Description text
                            Text("We need some personal information to create your own profile. These information will be only use for this application.")
                                .foregroundColor(.secondary)
                                .padding(.bottom, 10)
                            
                            // Form fields
                            VStack(alignment: .leading, spacing: 20) {
                                // Name field
                                Text("Name")
                                    .fontWeight(.medium)
                                CustomTextField(
                                    placeholder: "Name",
                                    imageName: "person",
                                    text: $name
                                )
                                
                                // Date of Birth field
                                Text("Date of Birth")
                                    .fontWeight(.medium)
                                ZStack {
                                    CustomTextField(
                                        placeholder: "DD/M/YY",
                                        imageName: "calendar",
                                        text: $dateOfBirth
                                    )
                                    
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            showDatePicker.toggle()
                                        }) {
                                            Image(systemName: "calendar")
                                                .foregroundColor(.blue)
                                                .padding(.trailing, 16)
                                        }
                                    }
                                }
                                
                                // Phone Number field
                                Text("Phone Number")
                                    .fontWeight(.medium)
                                CustomTextField(
                                    placeholder: "Phone",
                                    imageName: "phone",
                                    text: $phoneNumber
                                )
                                .keyboardType(.phonePad)
                                
                                // Address field
                                Text("Address")
                                    .fontWeight(.medium)
                                CustomTextField(
                                    placeholder: "Address",
                                    imageName: "location",
                                    text: $address
                                )
                            }
                            
                            // Show validation message if any
                            if let message = validationMessage {
                                Text(message)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.top, 8)
                            }
                            
                            Spacer(minLength: 30)
                            
                            // Complete button
                            Button(action: validateAndComplete) {
                                if isSubmitting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Complete")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.top, 20)
                            .disabled(isSubmitting)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle(currentStep < onboardingSteps.count ? "Onboarding" : "Your Information")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: 
                Button(action: {
                    if currentStep > 0 {
                        withAnimation {
                            currentStep -= 1
                        }
                    }
                }) {
                    if currentStep > 0 {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                }
            )
            .onAppear {
                loadUserData()
            }
            .sheet(isPresented: $showDatePicker) {
                DatePickerView(selectedDate: $selectedDate, dateString: $dateOfBirth)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func loadUserData() {
        if let user = authViewModel.currentUser {
            name = user.name
            address = user.address ?? ""
            phoneNumber = user.mobileNumber ?? ""
            if let dob = user.dateOfBirth, dob != "" {
                dateOfBirth = dob
                
                // Try to convert to DD/M/YY format if it's in YYYY-MM-DD format
                let inputFormatter = DateFormatter()
                inputFormatter.dateFormat = "yyyy-MM-dd"
                if let date = inputFormatter.date(from: dob) {
                    let outputFormatter = DateFormatter()
                    outputFormatter.dateFormat = "dd/M/yy"
                    dateOfBirth = outputFormatter.string(from: date)
                }
            }
        }
    }
    
    private func validateAndComplete() {
        // Clear previous validation message
        validationMessage = nil
        
        // Validate all fields
        if name.isEmpty {
            validationMessage = "Please enter your name."
            return
        }
        
        if dateOfBirth == "DD/M/YY" || dateOfBirth == "MM/DD/YYYY" {
            validationMessage = "Please select your date of birth."
            return
        }
        
        if phoneNumber.isEmpty {
            validationMessage = "Please enter your phone number."
            return
        }
        
        if address.isEmpty {
            validationMessage = "Please enter your address."
            return
        }
        
        // All validations passed, proceed with onboarding
        completeOnboarding()
    }
    
    private func completeOnboarding() {
        isSubmitting = true
        
        // Format date string to YYYY-MM-DD for API
        var formattedDate = dateOfBirth
        if dateOfBirth != "DD/M/YY" && dateOfBirth != "MM/DD/YYYY" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/M/yy"
            if let date = dateFormatter.date(from: dateOfBirth) {
                dateFormatter.dateFormat = "yyyy-MM-dd"
                formattedDate = dateFormatter.string(from: date)
            }
        }
        
        // Call the profile update API
        authViewModel.updateProfile(
            name: name,
            dateOfBirth: formattedDate,
            mobileNumber: phoneNumber,
            address: address
        ) { success, errorMessage in
            isSubmitting = false
            
            if !success {
                alertMessage = errorMessage ?? "Failed to update profile"
                showAlert = true
            }
        }
    }
}

// Model for onboarding steps
struct OnboardingStep {
    let title: String
    let description: String
    let animationName: String
}

// View for intro onboarding steps
struct OnboardingIntroView: View {
    let step: OnboardingStep
    let currentStep: Int
    let totalSteps: Int
    let onNext: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            // Lottie animation
            LottieView(animation: LottieAnimation.named(step.animationName))
                .looping()
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 280, height: 280)
                .padding(.bottom, 30)
            
            Text(step.title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 15)
            
            Text(step.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
            
            Spacer()
            
            // Progress indicators
            HStack(spacing: 8) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(index == currentStep ? .blue : .gray.opacity(0.3))
                }
            }
            .padding(.bottom, 30)
            
            Button(action: onNext) {
                Text("Next")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            
            Button(action: onSkip) {
                Text("Skip")
                    .foregroundColor(.gray)
                    .padding()
            }
            
            Spacer().frame(height: 20)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        let authVM = AuthViewModel()
        authVM.currentUser = User(
            id: 1, 
            name: "Jane Doe", 
            emailAddress: "jane@example.com", 
            address: "456 Oak Ave", 
            latitude: 11.0, 
            longitude: 107.0, 
            dateOfBirth: nil,
            mobileNumber: nil,
            onboarded: false,
            createdAt: "", 
            updatedAt: ""
        )
        
        return OnboardingView()
            .environmentObject(authVM)
    }
} 
