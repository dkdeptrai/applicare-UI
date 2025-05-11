//
//  SimpleChatView.swift
//  Applicare-UI
//

import SwiftUI

struct SimpleChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    // Add state for message count to force view refresh
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
            
            // Debug information
            VStack(alignment: .leading, spacing: 4) {
                Text("Debug Info")
                    .font(.headline)
                    .foregroundColor(.red)
                
                Text("Booking #\(booking.id)")
                Text("Status: \(booking.status)")
                Text("Loading: \(viewModel.isLoading ? "Yes" : "No")")
                Text("Messages count: \(viewModel.messages.count)")
                
                if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(Color.yellow.opacity(0.3))
            .cornerRadius(8)
            .padding(.horizontal)
            
            // Message list with ScrollViewReader
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        if viewModel.isLoading {
                            ProgressView("Loading messages...")
                                .padding()
                        } else if viewModel.messages.isEmpty {
                            Text("No messages")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(viewModel.messages) { message in
                                MessageRow(message: message)
                                    .id(message.id)
                            }
                            
                            // Invisible marker at bottom for scrolling
                            Color.clear
                                .frame(height: 1)
                                .id("bottomID")
                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: viewModel.messages.count) { _, newCount in
                    // Detect when messages are added
                    if newCount > messageCount {
                        messageCount = newCount
                        print("🟢 Message count changed: \(messageCount)")
                        
                        // Scroll to bottom when new messages arrive
                        withAnimation {
                            proxy.scrollTo("bottomID", anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    // Initial message count
                    messageCount = viewModel.messages.count
                    
                    // Initial scroll to bottom
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            proxy.scrollTo("bottomID", anchor: .bottom)
                        }
                    }
                }
            }
            .id(viewModel.messages.count) // Force view refresh when message count changes
            
            // Input field
            HStack {
                TextField("Type a message", text: $viewModel.messageText)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .disabled(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
            contactName: "John Smith"
        )
    }
} 