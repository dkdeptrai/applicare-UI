import SwiftUI

struct BookingCardContent: View {
    let booking: Booking
    let repairerName: String
    let formattedDate: String
    let formattedTime: String
    let statusColor: Color
    let showChat: Bool
    let onChat: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(repairerName)
                        .font(.headline)
                    Text("Booking #\(booking.id)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                HStack {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    Text(booking.status.capitalized)
                        .font(.caption)
                        .foregroundColor(statusColor)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(statusColor.opacity(0.1))
                .cornerRadius(12)
            }
            Text("Customer: \(booking.customerName)")
                .font(.subheadline)
                .foregroundColor(.primary)
            Divider()
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    Label {
                        Text(formattedDate)
                            .font(.subheadline)
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                    }
                    Label {
                        Text(formattedTime)
                            .font(.subheadline)
                    } icon: {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                    }
                }
                Spacer()
                if showChat, let onChat = onChat {
                    Button(action: onChat) {
                        HStack {
                            Text("Chat")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                            Image(systemName: "message.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            if let notes = booking.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
        .padding(.bottom, 8)
        .padding(.horizontal, 2)
    }
} 