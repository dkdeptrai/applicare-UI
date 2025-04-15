import SwiftUI

// Updated to match the design more closely
struct CompleteInfoView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    // State for form fields (re-added for editable form)
    @State private var name: String = ""
    @State private var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date() // Default example
    @State private var phoneNumber: String = ""
    @State private var address: String = ""
    
    // Re-add state variables for loading and error message
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    // Flag to indicate if data is loaded for editing
    @State private var didLoadData = false

    var isEditing: Bool // Determined by context (passed in or from authViewModel)

    var body: some View {
        // Removed NavigationView from here; it should be handled by the caller (e.g., SignUpView or ProfileSettingsView)
        // This allows it to be pushed or presented modally correctly.
        VStack(alignment: .leading, spacing: 15) { // Reduced spacing
            // Back button - managed by the NavigationView that presents this view
            
            Text("Complete your information")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 5)
            
            Text("We need some personal information to create your own profile. These information will be only use for this application.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 20)

            // Form Fields
            VStack(alignment: .leading, spacing: 15) {
                FormField(title: "Name", placeholder: "Name", text: $name)
                
                Text("Date of Birth").font(.subheadline).foregroundColor(.gray)
                HStack {
                    DatePicker(
                        "",
                        selection: $dateOfBirth,
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                    // Use accentColor for the picker's internal elements if needed
                    .accentColor(.blue) 
                    Spacer()
                    Image(systemName: "calendar") // Calendar Icon
                         .foregroundColor(.gray)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(8)

                FormField(title: "Phone Number", placeholder: "Phone", text: $phoneNumber, keyboardType: .phonePad)

                FormField(title: "Address", placeholder: "Address", text: $address)
                
                // Display error message if any
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top, 8)
                }
            }
            
            Spacer()

            // Action Button
            Button(action: {
                handleNextOrSave()
            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Next")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(isLoading || name.isEmpty || address.isEmpty)
        }
        .padding()
        // .navigationTitle("Fill in information") // Title set by presenting NavigationView
        // .navigationBarTitleDisplayMode(.inline)
        // .navigationBarBackButtonHidden(false) // Ensure back button is shown by default
        .onAppear(perform: loadUserDataForEditing) 
    }
    
    func loadUserDataForEditing() {
        // Prevent reloading if data already loaded or not in editing mode
        guard isEditing, !didLoadData, let user = authViewModel.currentUser else { return }
        
        print("Loading user data for editing...")
        name = user.name
        address = user.address ?? ""
        phoneNumber = user.mobileNumber ?? ""
        
        // Parse date of birth if available
        if let dobString = user.dateOfBirth, !dobString.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let dob = dateFormatter.date(from: dobString) {
                dateOfBirth = dob
            }
        }
        
        didLoadData = true
    }
    
    func handleNextOrSave() {
        print("Next/Save Tapped")
        print("Name: \(name)")
        print("DOB: \(dateOfBirth)")
        print("Phone: \(phoneNumber)")
        print("Address: \(address)")
        
        // Format date to string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dobString = dateFormatter.string(from: dateOfBirth)
        
        isLoading = true
        
        if isEditing {
            // Save profile using the AuthViewModel
            authViewModel.updateProfile(
                name: name, 
                dateOfBirth: dobString, 
                mobileNumber: phoneNumber, 
                address: address
            ) { success, error in
                isLoading = false
                if success {
                    print("Profile updated successfully")
                    dismiss() // Dismiss after saving
                } else {
                    errorMessage = error ?? "Failed to update profile"
                    print("Error updating profile: \(errorMessage ?? "")")
                }
            }
        } else {
            // Logic after completing initial info during sign up
            authViewModel.updateProfile(
                name: name, 
                dateOfBirth: dobString, 
                mobileNumber: phoneNumber, 
                address: address
            ) { success, error in
                isLoading = false
                if success {
                    print("Profile completed successfully")
                    dismiss() // Dismiss after saving
                } else {
                    errorMessage = error ?? "Failed to complete profile"
                    print("Error completing profile: \(errorMessage ?? "")")
                }
            }
        }
    }
    
    // TODO: Re-add saveProfile() when API is ready
    /*
    func saveProfile() {
        isLoading = true
        errorMessage = nil
        let updatedInfo = UpdateProfileDTO(name: name, address: address, /* ... other fields ... */)
        authViewModel.updateProfile(userInfo: updatedInfo) { success in ... }
    }
    */
}

// Helper for standard text field form layout
struct FormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

// Remove UpdateProfileDTO
// struct UpdateProfileDTO: Codable { ... }

// Reusable Button Style (Example)
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isEnabled ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

// Preview needs adjustment
struct CompleteInfoView_Previews: PreviewProvider {
    static var previews: some View {
         // Use Group to return multiple previews
         Group {
             // Preview for initial completion
             NavigationView { 
                 CompleteInfoView(isEditing: false)
                     .environmentObject(AuthViewModel())
                     .navigationTitle("Fill Info") 
             }
             .previewDisplayName("Initial Completion")

             // Preview for editing
             // Set up the ViewModel first
             let editVM: AuthViewModel = {
                 let vm = AuthViewModel()
                 vm.currentUser = User(
                     id: 1, 
                     name: "Jane Doe", 
                     emailAddress: "jane@test.com", 
                     address: "123 Main St", 
                     latitude: nil, 
                     longitude: nil, 
                     dateOfBirth: nil,
                     mobileNumber: nil,
                     onboarded: false,
                     createdAt: "", 
                     updatedAt: ""
                 )
                 vm.isAuthenticated = true // Also set authenticated state for consistency
                 return vm
             }() // Immediately execute the closure to assign the configured VM
             
             // Then use the VM in the NavigationView
             NavigationView { 
                  CompleteInfoView(isEditing: true)
                      .environmentObject(editVM)
                      .navigationTitle("Edit Profile") 
             }
             .previewDisplayName("Editing Profile")
         }
    }
}