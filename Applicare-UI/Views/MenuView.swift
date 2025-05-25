import SwiftUI

struct MenuView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSettings = false
    
    var body: some View {
        VStack(spacing: 24) {
            Button(action: { showSettings = true }) {
                HStack {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text("Settings")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showSettings) {
            ProfileSettingsView().environmentObject(authViewModel)
        }
        .navigationTitle("Menu")
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView().environmentObject(AuthViewModel())
    }
} 