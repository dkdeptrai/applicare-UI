//
//  SimpleChatView.swift
//  Applicare-UI
//

import SwiftUI

struct SimpleChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    // State variable no longer needed
    @State private var messageCount: Int = 0
    @State private var scrollToBottom: Bool = false
    
    let booking: Booking
    let contactName: String
    
    var body: some View {
        VStack {
            // Simple header with back button
            HStack {
                Button(action: {
                    print("🟢 Back button pressed in SimpleChatView")
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                
                Spacer()
                
                Text(contactName)
                    .font(.headline)
                
                Spacer()
            }
            .padding()
            .background(Color.blue.opacity(0.2))
            
//            // Debug information
//            VStack(alignment: .leading, spacing: 4) {
//                Text("Debug Info")
//                    .font(.headline)
//                    .foregroundColor(.red)
//                
//                Text("Booking #\(booking.id)")
//                Text("Status: \(booking.status)")
//                Text("Loading: \(viewModel.isLoading ? "Yes" : "No")")
//                Text("Messages count: \(viewModel.messages.count)")
//                Text("Connection: \(viewModel.connectionState.rawValue)")
//                
//                if let error = viewModel.errorMessage {
//                    Text("Error: \(error)")
//                        .foregroundColor(.red)
//                        .onTapGesture {
//                            viewModel.retryConnection()
//                        }
//                }
//            }
//            .padding()
//            .background(Color.yellow.opacity(0.3))
//            .cornerRadius(8)
//            .padding(.horizontal)
            
            // Message list with INVERTED scroll approach
            ScrollView {
                VStack(spacing: 12) {
                    // Show messages in reverse order due to the flip
                    if !viewModel.messages.isEmpty {
                        ForEach(viewModel.messages.reversed()) { message in
                            MessageRow(message: message)
                                .id(message.id)
                                // Counteract the scroll view rotation
                                .rotationEffect(.degrees(180))
                        }
                    } else if viewModel.isLoading {
                        ProgressView("Loading messages...")
                            .padding()
                            .rotationEffect(.degrees(180))
                    } else if viewModel.connectionState == .connected {
                        Text("No messages")
                            .foregroundColor(.gray)
                            .padding()
                            .rotationEffect(.degrees(180))
                    } else if viewModel.connectionState == .connecting || viewModel.connectionState == .reconnecting {
                        VStack(spacing: 8) {
                            ProgressView()
                                .padding(.bottom, 10)
                            Text("Establishing connection...")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .rotationEffect(.degrees(180))
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
                        .padding()
                        .rotationEffect(.degrees(180))
                    }
                }
                .padding(.vertical)
            }
            // This rotation effect is the key to the inverted scroll
            .rotationEffect(.degrees(180))
            
            // Connection status indicator
            if viewModel.connectionState != .connected {
                HStack {
                    Circle()
                        .fill(connectionStatusColor)
                        .frame(width: 10, height: 10)
                    Text(viewModel.connectionState.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.retryConnection()
                    }) {
                        HStack(spacing: 4) {
                            Text("Retry")
                                .font(.caption)
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .padding(.horizontal)
            }
            
            // Input field with clear connection state indication
            HStack {
                TextField("Type a message", text: $viewModel.messageText)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .disabled(viewModel.connectionState != .connected)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(viewModel.connectionState == .connected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(viewModel.connectionState == .connected ? Color.blue : Color.gray)
                        .clipShape(Circle())
                }
                .disabled(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
                          viewModel.connectionState != .connected)
                .opacity(viewModel.connectionState == .connected ? 1.0 : 0.6)
            }
            .padding()
        }
        .navigationBarHidden(true)
        .onAppear {
            print("🟢 SimpleChatView appeared for booking #\(booking.id)")
            viewModel.loadChat(forBookingId: booking.id)
        }
        .onDisappear {
            print("🟢 SimpleChatView disappeared")
            viewModel.disconnect()
        }
    }
    
    // Helper for connection status color
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
}

// Extract the message row into a separate component
struct MessageRow: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser() {
                Spacer()
            }
            
            VStack(alignment: message.isFromCurrentUser() ? .trailing : .leading) {
                Text(message.displayName)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(message.content)
                    .padding()
                    .background(message.isFromCurrentUser() ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(message.isFromCurrentUser() ? .white : .black)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 8)
            
            if !message.isFromCurrentUser() {
                Spacer()
            }
        }
    }
}

struct SimpleChatView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleChatView(
            booking: Booking.sampleBooking(
                repairer_note: "This is a recurring customer with similar issues"
            ),
            contactName: "John Smith"
        )
    }
} 
