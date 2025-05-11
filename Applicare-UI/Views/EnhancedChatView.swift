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
                        // DEBUG INFORMATION
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DEBUG INFO")
                                .font(.headline)
                                .foregroundColor(.red)
                                .padding(5)
                                .background(Color.yellow)
                            
                            Text("Booking ID: \(booking.id)")
                            Text("Status: \(booking.status)")
                            Text("Message count: \(viewModel.messages.count)")
                            Text("Is loading: \(viewModel.isLoading ? "Yes" : "No")")
                            
                            if let error = viewModel.errorMessage {
                                Text("Error: \(error)")
                                    .foregroundColor(.red)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                        // Booking status card
                        bookingStatusCard
                            .padding(.horizontal)
                        
                        // Messages area
                        if viewModel.isLoading {
                            ProgressView("Loading messages...")
                                .padding()
                        } else if viewModel.messages.isEmpty {
                            Text("No messages yet")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            messagesView
                        }
                        
                        // Empty space to allow scrolling up
                        Spacer().frame(height: 30)
                    }
                    .padding(.bottom, 10)
                }
                
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
            TextField("Type a message...", text: $viewModel.messageText)
                .padding(10)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(20)
            
            Button(action: {
                viewModel.sendMessage()
            }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.blue)
                    .padding(10)
            }
            .disabled(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding([.horizontal, .bottom])
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
                booking: Booking(
                    id: 1,
                    repairer_id: 123,
                    service_id: 456,
                    start_time: "2023-12-20T08:00:00.000Z",
                    end_time: "2023-12-20T10:00:00.000Z",
                    status: "confirmed",
                    address: "123 Main St",
                    notes: "Please bring tools for a leaky faucet repair",
                    created_at: "2023-12-15T09:30:00.000Z",
                    updated_at: "2023-12-15T09:30:00.000Z"
                ),
                contactName: "Ricardo"
            )
        }
    }
} 