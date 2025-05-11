//
//  ChatViewModel.swift
//  Applicare-UI
//

import Foundation
import SwiftUI

class ChatViewModel: ObservableObject, ChatMessageDelegate {
    @Published var messages: [Message] = []
    @Published var messageText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private var chatService: ChatNetworkServiceProtocol
    private var bookingId: Int?
    
    init(chatService: ChatNetworkServiceProtocol = ChatNetworkService.shared) {
        self.chatService = chatService
        self.chatService.messageDelegate = self
    }
    
    // MARK: - Public Methods
    
    func loadChat(forBookingId bookingId: Int) {
        self.bookingId = bookingId
        isLoading = true
        errorMessage = nil
        
        print("Loading chat for booking #\(bookingId)")
        
        // Load message history
        chatService.getMessages(bookingId: bookingId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let messages):
                    print("Successfully loaded \(messages.count) messages")
                    
                    // Debug: Print the first message to verify its format
                    if let firstMessage = messages.first {
                        print("First message: id=\(firstMessage.id), content=\"\(firstMessage.content)\"")
                        print("Sender: type=\(firstMessage.sender_type), id=\(firstMessage.sender_id)")
                        print("Sender info: \(String(describing: firstMessage.sender_info))")
                    }
                    
                    self?.messages = messages.sorted(by: { $0.created_at < $1.created_at })
                    
                    // Schedule reconnection check after a delay
                    self?.scheduleReconnectionCheck(bookingId: bookingId)
                    
                case .failure(let error):
                    self?.errorMessage = "Failed to load messages: \(error.localizedDescription)"
                    print("Error loading messages: \(error)")
                }
            }
        }
        
        // Connect to WebSocket for real-time updates
        chatService.connectToChat(bookingId: bookingId)
    }
    
    func sendMessage() {
        guard let bookingId = bookingId, !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let messageContent = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        print("📤 Sending message: \"\(messageContent)\" to booking #\(bookingId)")
        
        // Clear the input text immediately
        messageText = ""
        
        // Send message to server and wait for WebSocket to deliver it back
        chatService.sendMessage(bookingId: bookingId, content: messageContent) { [weak self] result in
            switch result {
            case .success:
                print("📤 Message sent successfully to server - waiting for WebSocket update")
                // Do not update UI - rely on WebSocket to deliver the new message
                
            case .failure(let error):
                print("📤 Error sending message: \(error)")
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to send: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func disconnect() {
        chatService.disconnectFromChat()
    }
    
    // MARK: - ChatMessageDelegate
    
    func didReceiveMessage(_ message: Message, forBookingId: Int) {
        print("⚠️ DEBUGGING DELEGATE CALLBACK ⚠️")
        print("📥 ViewModel received message: id=\(message.id), content=\"\(message.content)\"")
        print("📥 Current bookingId: \(String(describing: self.bookingId))")
        print("📥 Message bookingId: \(bookingId)")
        
        guard forBookingId == self.bookingId else { 
            print("📥 Ignored message for booking #\(forBookingId) (current: #\(self.bookingId ?? 0))")
            return 
        }
        
        print("📥 Message ACCEPTED - Handling in UI")
        print("📥 Message details:")
        print("  - Content: \"\(message.content)\"")
        print("  - Sender: \(message.sender_type) (ID: \(message.sender_id))")
        print("  - Name: \(message.displayName)")
        print("  - Is from current user? \(message.isFromCurrentUser() ? "Yes" : "No")")
        print("  - Created at: \(message.created_at)")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                print("❌ Self was deallocated before updating UI")
                return
            }
            
            // Check if message already exists
            if let existingIndex = self.messages.firstIndex(where: { $0.id == message.id }) {
                print("📥 Message already exists at index \(existingIndex), not adding duplicate")
                return
            }
            
            // Add the new message
            print("📥 Adding new message to UI collection")
            self.messages.append(message)
            self.messages.sort(by: { $0.created_at < $1.created_at })
            
            // Force view update through a dummy property change
            let count = self.messages.count
            self.objectWillChange.send()
            print("📥 Updated messages array, now contains \(count) messages")
        }
    }
    
    // MARK: - Mock Data for Testing
    
    #if DEBUG
    private func addMockMessages(bookingId: Int) {
        print("Adding mock messages for testing")
        
        // Create some mock messages for testing
        let currentDate = Date()
        let calendar = Calendar.current
        
        // Mock message 1 - from other user (5 minutes ago)
        let date1 = calendar.date(byAdding: .minute, value: -5, to: currentDate)!
        let dateString1 = ISO8601DateFormatter().string(from: date1)
        let message1 = Message(
            id: 1,
            content: "Hello! I'm looking forward to our appointment.",
            sender_type: "Repairer",
            sender_id: 456,
            sender_name: "Repairer",
            created_at: dateString1
        )
        
        // Mock message 2 - from current user (3 minutes ago)
        let date2 = calendar.date(byAdding: .minute, value: -3, to: currentDate)!
        let dateString2 = ISO8601DateFormatter().string(from: date2)
        let message2 = Message(
            id: 2,
            content: "Great! Do you need any specific information before you arrive?",
            sender_type: "User",
            sender_id: AuthNetworkService.shared.getUserId() ?? 123,
            sender_name: "You",
            created_at: dateString2
        )
        
        // Mock message 3 - reschedule message (1 minute ago)
        let date3 = calendar.date(byAdding: .minute, value: -1, to: currentDate)!
        let dateString3 = ISO8601DateFormatter().string(from: date3)
        let message3 = Message(
            id: 3,
            content: "Reschedule request for December 20",
            sender_type: "Repairer",
            sender_id: 456,
            sender_name: "Repairer",
            created_at: dateString3
        )
        
        // Add messages to the chat
        messages = [message1, message2, message3]
    }
    #endif
    
    private func scheduleReconnectionCheck(bookingId: Int) {
        // After 5 seconds, check if we're receiving real-time messages
        // If only receiving pings, force a reconnection
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self = self, self.bookingId == bookingId else { return }
            
            print("🔍 Checking WebSocket status - forcing reconnection to ensure real-time messages")
            (self.chatService as? ChatNetworkService)?.reconnectToChat(bookingId: bookingId)
        }
    }
} 