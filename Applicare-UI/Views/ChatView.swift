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
    
    init(booking: Booking, contactName: String) {
        self.booking = booking
        self.contactName = contactName
    }
    
    var body: some View {
        VStack {
            // Chat header
            HStack {
                VStack(alignment: .leading) {
                    Text(contactName)
                        .font(.headline)
                    Text("Booking #\(booking.id)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Optional: Add status indicator
                Circle()
                    .fill(Color.green)
                    .frame(width: 10, height: 10)
                Text("Online")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            
            // Messages list
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        } else if viewModel.messages.isEmpty {
                            VStack {
                                Spacer().frame(height: 100)
                                Text("No messages yet")
                                    .foregroundColor(.gray)
                                Text("Start the conversation!")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.top, 5)
                            }
                        } else {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(
                                    message: message,
                                    isFromCurrentUser: message.isFromCurrentUser()
                                )
                                .id(message.id)
                            }
                        }
                        
                        // Invisible marker view at the bottom for scrolling
                        Text("")
                            .id("bottomMarker")
                            .opacity(0)
                    }
                }
                .onChange(of: viewModel.messages.count) { oldCount, newCount in
                    withAnimation {
                        scrollView.scrollTo("bottomMarker", anchor: .bottom)
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            scrollView.scrollTo("bottomMarker", anchor: .bottom)
                        }
                    }
                }
            }
            
            // Display error if there is one
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            // Message input
            HStack {
                TextField("Type a message...", text: $viewModel.messageText)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(20)
                
                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(Color.blue)
                        )
                }
                .disabled(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
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
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatView(
                booking: Booking(
                    id: 1,
                    repairer_id: 123,
                    service_id: 456,
                    start_time: "2023-08-01T10:00:00.000Z",
                    end_time: "2023-08-01T12:00:00.000Z",
                    status: "confirmed",
                    address: "123 Main St",
                    notes: "Please bring tools for a leaky faucet repair",
                    created_at: "2023-07-25T09:30:00.000Z",
                    updated_at: "2023-07-25T09:30:00.000Z"
                ),
                contactName: "John Doe"
            )
        }
    }
} 