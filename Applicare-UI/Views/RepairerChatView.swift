//
//  RepairerChatView.swift
//  Applicare-UI
//

import SwiftUI

struct RepairerChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    let booking: Booking
    let customerName: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom navigation header with fixed height
            ZStack {
                Color.blue
                    .edgesIgnoringSafeArea(.top)
                
                VStack {
                    HStack {
                        Button(action: {
                            print("❌ Close button tapped - navigating back from chat")
                            viewModel.disconnect()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "xmark")
                                Text("Close")
                            }
                            .foregroundColor(.white)
                            .padding(.leading)
                        }
                        
                        Spacer()
                        
                        Text(customerName)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Connection status indicator
                        Circle()
                            .fill(connectionStatusColor)
                            .frame(width: 10, height: 10)
                            .padding(.trailing)
                    }
                    .padding(.top, 45) // Extra padding for safe area at top
                    .padding(.bottom, 10)
                }
            }
            .frame(minHeight: 90) // Minimum height for the header
            
            // Booking details card
            bookingDetailsCard
                .padding(.horizontal)
                .padding(.top)
            
            // Connection status if not connected
            if viewModel.connectionState != .connected {
                connectionStatusView
                    .padding(.horizontal)
                    .padding(.vertical, 8)
            }
            
            // Content area with INVERTED scroll approach
            ScrollView {
                VStack(spacing: 12) {
                    // Messages area
                    if viewModel.isLoading {
                        ProgressView("Loading messages...")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .rotationEffect(.degrees(180))
                    } else if viewModel.messages.isEmpty {
                        emptyStateView
                            .rotationEffect(.degrees(180))
                    } else {
                        // Direct display of messages in REVERSE order
                        ForEach(viewModel.messages.reversed()) { message in
                            RepairerMessageBubble(message: message)
                                .padding(.horizontal)
                                // Rotate each bubble to counter the scroll view rotation
                                .rotationEffect(.degrees(180))
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
            // This rotation effect is the key to the inverted scroll
            .rotationEffect(.degrees(180))
            
            // Error message banner
            if let errorMessage = viewModel.errorMessage {
                Button(action: {
                    viewModel.retryConnection()
                }) {
                    HStack {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                        
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            
            // Message input area
            VStack(spacing: 8) {
                // Input field and send button
                HStack {
                    TextField("Type a message", text: $viewModel.messageText)
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(20)
                        .disabled(viewModel.connectionState != .connected)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(viewModel.connectionState == .connected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    Button(action: {
                        viewModel.sendMessage()
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(viewModel.connectionState == .connected ? Color.blue : Color.gray)
                            )
                    }
                    .disabled(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
                             viewModel.connectionState != .connected)
                    .opacity(viewModel.connectionState == .connected ? 1.0 : 0.6)
                    .padding(.leading, 8)
                }
                .padding()
            }
            .background(Color(UIColor.systemBackground))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -5)
        }
        .background(Color(UIColor.systemBackground))
        .edgesIgnoringSafeArea([.bottom]) // Only ignore safe area at bottom, not top
        .navigationBarHidden(true)
        .onAppear {
            print("📱 RepairerChatView appeared for booking #\(booking.id) with customer \(customerName)")
            viewModel.loadChat(forBookingId: booking.id)
        }
        .onDisappear {
            print("📱 RepairerChatView disappeared - disconnecting WebSocket")
            viewModel.disconnect()
        }
    }
    
    // MARK: - Helper Views
    
    private var connectionStatusColor: Color {
        switch viewModel.connectionState {
        case .connected:
            return Color.green
        case .connecting, .reconnecting:
            return Color.orange
        case .disconnected, .error, .authError:
            return Color.red
        }
    }
    
    private var bookingDetailsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Booking #\(booking.id)")
                .font(.headline)
            
            Text("Status: \(booking.status.capitalized)")
                .font(.subheadline)
                .foregroundColor(booking.status == "confirmed" ? .green : .orange)
            
            HStack {
                Image(systemName: "calendar")
                Text(formatDate(dateString: booking.start_time))
            }
            .font(.subheadline)
            
            HStack {
                Image(systemName: "clock")
                Text("\(formatTime(dateString: booking.start_time)) - \(formatTime(dateString: booking.end_time))")
            }
            .font(.subheadline)
            
            if !booking.address.isEmpty {
                HStack {
                    Image(systemName: "location")
                    Text(booking.address)
                }
                .font(.subheadline)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    private var connectionStatusView: some View {
        HStack {
            Circle()
                .fill(connectionStatusColor)
                .frame(width: 10, height: 10)
            Text(viewModel.connectionState.rawValue)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Button(action: {
                viewModel.retryConnection()
            }) {
                HStack {
                    Text("Retry")
                        .font(.caption)
                    Image(systemName: "arrow.clockwise")
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(20)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 10) {
            if viewModel.connectionState == .connected {
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 40))
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.bottom, 5)
                
                Text("No messages yet")
                    .foregroundColor(.gray)
                
                Text("Start the conversation with \(customerName)")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else if viewModel.connectionState == .connecting || viewModel.connectionState == .reconnecting {
                VStack(spacing: 8) {
                    ProgressView()
                        .padding(.bottom, 10)
                    Text("Establishing connection...")
                        .foregroundColor(.gray)
                }
            } else {
                Button(action: {
                    viewModel.retryConnection()
                }) {
                    VStack(spacing: 8) {
                        Text("Connection issue")
                            .foregroundColor(.red)
                        Text("Tap to retry")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                            .padding(8)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(30)
    }
    
    // MARK: - Helper Functions
    
    private func formatDate(dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "EEE, dd MMMM"
            return displayFormatter.string(from: date)
        }
        return "Unknown date"
    }
    
    private func formatTime(dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "h:mm a"
            return displayFormatter.string(from: date)
        }
        return "Unknown time"
    }
}

// MARK: - Message Bubble Component for Repairer View

struct RepairerMessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            // Spacer for repairer's messages (from current user)
            if message.isFromCurrentUser() {
                Spacer()
            }
            
            // Message content
            VStack(alignment: message.isFromCurrentUser() ? .trailing : .leading, spacing: 4) {
                // Sender name
                if !message.isFromCurrentUser() {
                    Text(message.displayName)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                }
                
                // Message bubble
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(message.isFromCurrentUser() ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(message.isFromCurrentUser() ? .white : .primary)
                        .cornerRadius(16)
                }
                
                // Time
                Text(message.formattedTime)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .padding(.top, 2)
            }
            .padding(.vertical, 2)
            
            // Spacer for customer's messages
            if !message.isFromCurrentUser() {
                Spacer()
            }
        }
    }
}

struct RepairerChatView_Previews: PreviewProvider {
    static var previews: some View {
        RepairerChatView(
            booking: Booking.sampleBooking(
                status: "confirmed",
                repairer_note: "Customer has reported slow drain"
            ),
            customerName: "John Smith"
        )
    }
} 