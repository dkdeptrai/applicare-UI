//
//  EnhancedChatView.swift
//  Applicare-UI
//

import SwiftUI

struct EnhancedChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var scrolledToBottom = false
    
    // For additional functionality as shown in the image
    @State private var showRescheduleOptions = false
    
    let booking: Booking
    let contactName: String
    
    var body: some View {
        ZStack {
            // Main background
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Custom navigation header
                ZStack {
                    Color.blue
                        .frame(height: 60)
                        .edgesIgnoringSafeArea(.top)
                    
                    HStack {
                        Button(action: {
                            print("⬅️ Back button tapped")
                            viewModel.disconnect()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                Text("Back")
                            }
                            .foregroundColor(.white)
                            .padding(.leading)
                        }
                        
                        Spacer()
                        
                        Text(contactName)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Placeholder to balance the layout
                        Text("    ")
                            .padding(.trailing)
                    }
                }
                
                ScrollView {
                    VStack(spacing: 20) {
//                        // DEBUG INFORMATION
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text("DEBUG INFO")
//                                .font(.headline)
//                                .foregroundColor(.red)
//                                .padding(5)
//                                .background(Color.yellow)
//                            
//                            Text("Booking ID: \(booking.id)")
//                            Text("Status: \(booking.status)")
//                            Text("Message count: \(viewModel.messages.count)")
//                            Text("Is loading: \(viewModel.isLoading ? "Yes" : "No")")
//                            Text("Connection: \(viewModel.connectionState.rawValue)")
//                            
//                            if let error = viewModel.errorMessage {
//                                Text("Error: \(error)")
//                                    .foregroundColor(.red)
//                                Button("Retry Connection") {
//                                    viewModel.retryConnection()
//                                }
//                                .font(.caption)
//                                .padding(.vertical, 4)
//                                .padding(.horizontal, 10)
//                                .background(Color.blue)
//                                .foregroundColor(.white)
//                                .cornerRadius(20)
//                            }
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding()
//                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(10)
//                        .padding(.horizontal)
                        
                        // Booking status card
                        bookingStatusCard
                            .padding(.horizontal)
                        
                        // Connection status if not connected
                        if viewModel.connectionState != .connected {
                            connectionStatusView
                                .padding(.horizontal)
                        }
                        
                        // Messages area
                        if viewModel.isLoading {
                            ProgressView("Loading messages...")
                                .padding()
                        } else if viewModel.messages.isEmpty {
                            if viewModel.connectionState == .connected {
                                Text("No messages yet")
                                    .foregroundColor(.gray)
                                    .padding()
                            } else if viewModel.connectionState == .connecting || viewModel.connectionState == .reconnecting {
                                VStack(spacing: 8) {
                                    ProgressView()
                                        .padding(.bottom, 10)
                                    Text("Establishing connection...")
                                        .foregroundColor(.gray)
                                }
                                .padding()
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
                            }
                        } else {
                            messagesView
                        }
                        
                        // Empty space to allow scrolling up
                        Spacer().frame(height: 30)
                    }
                    .padding(.bottom, 10)
                }
                .id("\(viewModel.messages.count)-\(viewModel.connectionState)") // Force view refresh when state changes
                
                // Message input area
                messageInputField
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            print("📱 EnhancedChatView appeared for booking #\(booking.id)")
            viewModel.loadChat(forBookingId: booking.id)
        }
        .onDisappear {
            print("📱 EnhancedChatView disappeared - disconnecting WebSocket")
            viewModel.disconnect()
        }
    }
    
    // MARK: - View Components
    
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
    
    private var bookingStatusCard: some View {
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
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    private var messagesView: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.messages) { message in
                MessageBubble(message: message, isFromCurrentUser: message.isFromCurrentUser())
                    .padding(.horizontal)
            }
        }
    }
    
    private var messageInputField: some View {
        HStack {
            TextField("Type a message", text: $viewModel.messageText)
                .padding(12)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(20)
                .disabled(viewModel.connectionState != .connected)
            
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
            .padding(.leading, 8)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -5)
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

struct EnhancedChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EnhancedChatView(
                booking: Booking.sampleBooking(
                    repairer_note: "Need to check water pressure in this area"
                ),
                contactName: "Ricardo"
            )
        }
    }
} 
