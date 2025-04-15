import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var dateOfBirth: String = "DD/M/YY"
    @State private var phoneNumber: String = ""
    @State private var address: String = ""
    @State private var showDatePicker: Bool = false
    @State private var selectedDate: Date = Date()
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
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
                
                Spacer(minLength: 30)
                
                // Next button
                Button(action: saveProfile) {
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
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.top, 20)
                .disabled(isLoading || name.isEmpty || address.isEmpty)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Fill in information")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
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
    
    private func loadUserData() {
        if let user = authViewModel.currentUser {
            name = user.name
            address = user.address ?? ""
            phoneNumber = user.mobileNumber ?? ""
            
            if let dob = user.dateOfBirth, !dob.isEmpty {
                dateOfBirth = dob
                
                // Try to convert to MM/DD/YYYY format if it's in YYYY-MM-DD format
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
    
    private func saveProfile() {
        isLoading = true
        
        // Format date from dd/M/yy to YYYY-MM-DD for the API
        var apiDateFormat = dateOfBirth
        if dateOfBirth != "MM/DD/YYYY" {
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "dd/M/yy"
            if let date = inputFormatter.date(from: dateOfBirth) {
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = "yyyy-MM-dd"
                apiDateFormat = outputFormatter.string(from: date)
            }
        }
        
        // Call the profile update API
        authViewModel.updateProfile(
            name: name,
            dateOfBirth: apiDateFormat,
            mobileNumber: phoneNumber,
            address: address
        ) { success, error in
            isLoading = false
            
            if success {
                // Profile updated successfully, dismiss the view
                dismiss()
            } else {
                // Show error alert
                alertMessage = error ?? "Failed to update profile"
                showAlert = true
            }
        }
    }
}

struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Binding var dateString: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select a date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                
                Button("Done") {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd/M/yy"
                    dateString = formatter.string(from: selectedDate)
                    dismiss()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}

// MARK: - Preview
struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let authVM = AuthViewModel()
        authVM.currentUser = User(
            id: 1, 
            name: "Jane Doe", 
            emailAddress: "jane@example.com", 
            address: "456 Oak Ave", 
            latitude: 11.0, 
            longitude: 107.0, 
            dateOfBirth: "1985-06-15",
            mobileNumber: "+1987654321",
            onboarded: true,
            createdAt: "", 
            updatedAt: ""
        )
        authVM.isAuthenticated = true
        
        return NavigationView {
            ProfileSettingsView()
        }
        .environmentObject(authVM)
    }
} 