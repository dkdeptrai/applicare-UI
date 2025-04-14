import SwiftUI

// Helper view for consistent row display in profile/settings screens
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }
}

// Optional: Add a preview for InfoRow itself
#Preview {
    InfoRow(label: "Email", value: "test@example.com")
        .padding()
} 