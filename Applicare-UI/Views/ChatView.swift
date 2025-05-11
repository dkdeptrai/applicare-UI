//
//  ChatView.swift
//  Applicare-UI
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var scrolledToBottom = false
    
    let booking: Booking
    let contactName: String
    let isRepairer: Bool // Flag to determine if we're in repairer mode
    
    init(booking: Booking, contactName: String, isRepairer: Bool = false) {
        self.booking = booking
        self.contactName = contactName
        self.isRepairer = isRepairer
    }
    
    var body: some View {
        VStack {
            // Chat header with connection status
            HStack {
                VStack(alignment: .leading) {
                    Text(contactName)
                        .font(.headline)
                    Text("Booking #\(booking.id)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Connection status indicator
                connectionStatusView
            }
            .padding()
            
            // Messages list with INVERTED scroll approach
            ScrollView {
                LazyVStack {
                    // The actual messages - this is intentionally backwards
                    // as we flip the entire scroll view
                    if !viewModel.messages.isEmpty {
                        ForEach(viewModel.messages.reversed()) { message in
                            MessageBubble(
                                message: message,
                                isFromCurrentUser: isRepairer ? message.isFromRepairer() : message.isFromCurrentUser()
                            )
                            .id(message.id)
                            // Rotate each message to counteract the scroll view rotation
                            .rotationEffect(.degrees(180))
                        }
                    } else if viewModel.isLoading {
                        loadingView
                            // Rotate loading view to make it appear correctly
                            .rotationEffect(.degrees(180))
                    } else {
                        emptyStateView
                            // Rotate empty state to make it appear correctly
                            .rotationEffect(.degrees(180))
                    }
                }
            }
            // This rotation effect is the key to the inverted scroll
            .rotationEffect(.degrees(180))
            
            // Display error if there is one
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
            
            // Message input with connection status
            VStack(spacing: 8) {
                // Connection status bar
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
                            }
                        }
                        .font(.caption)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                // Input field and send button
                HStack {
                    TextField("Type a message...", text: $viewModel.messageText)
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
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
                }
                .padding()
            }
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadChat(forBookingId: booking.id)
        }
        .onDisappear {
            viewModel.disconnect()
        }
    }
    
    // MARK: - Helper Views
    
    private var connectionStatusView: some View {
        HStack {
            Circle()
                .fill(connectionStatusColor)
                .frame(width: 10, height: 10)
            Text(viewModel.connectionState.rawValue)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    private var connectionStatusColor: Color {
        switch viewModel.connectionState {
        case .connected:
            return Color.green
        case .connecting, .reconnecting:
            return Color.orange
        case .disconnected, .error:
            return Color.red
        case .authError:
            return Color.red
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .padding()
            Text("Connecting to chat...")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer().frame(height: 100)
            if viewModel.needsReauthentication {
                // Authentication error - show login prompt
                reauthenticationPromptView
            } else if viewModel.connectionState == .connected {
                VStack(spacing: 8) {
                    Text("No messages yet")
                        .foregroundColor(.gray)
                    Text("Start the conversation!")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
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
    }
    
    // New view for reauthentication prompt
    private var reauthenticationPromptView: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.shield")
                .font(.largeTitle)
                .foregroundColor(.red)
                .padding(.bottom, 8)
            
            Text("Authentication Required")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Your session has expired. Please close this screen and log in again.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                // Dismiss the current view to allow user to log in again
                // This assumes the parent view will handle the dismissal appropriately
                viewModel.disconnect()
            }) {
                Text("Close Chat")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding()
    }
    
    // MARK: - Repairer-specific components
    
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
    
    // Helper functions for date formatting
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

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatView(
                booking: Booking.sampleBooking(
                    repairer_note: "Customer has had this issue before - bring extra washers"
                ),
                contactName: "John Doe"
            )
        }
    }
} 