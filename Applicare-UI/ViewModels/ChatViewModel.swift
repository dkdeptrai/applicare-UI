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
    @Published var connectionState: ConnectionState = .disconnected
    @Published var needsReauthentication: Bool = false
    
    // Callback for when messages are updated
    var onMessagesUpdated: ((Int) -> Void)?
    
    // Add state enum for more granular status reporting
    enum ConnectionState: String {
        case disconnected = "Disconnected"
        case connecting = "Connecting..."
        case connected = "Connected"
        case reconnecting = "Reconnecting..."
        case error = "Connection error"
        case authError = "Authentication error"
    }
    
    private var chatService: ChatNetworkServiceProtocol
    private var bookingId: Int?
    private var connectionAttempts: Int = 0
    private var maxConnectionAttempts: Int = 3
    
    init(chatService: ChatNetworkServiceProtocol = ChatNetworkService.shared) {
        self.chatService = chatService
        self.chatService.messageDelegate = self
        
        // Set up notification observers for token refresh failures
        setupAuthNotifications()
    }
    
    deinit {
        // Remove notification observers
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupAuthNotifications() {
        // Listen for user reauthentication required notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserReauthenticationRequired),
            name: .userReauthenticationRequired,
            object: nil
        )
        
        // Listen for repairer reauthentication required notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRepairerReauthenticationRequired),
            name: .repairerReauthenticationRequired,
            object: nil
        )
    }
    
    @objc private func handleUserReauthenticationRequired() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("🔐 User authentication expired - reauthentication required")
            self.needsReauthentication = true
            self.connectionState = .authError
            self.errorMessage = "Authentication expired. Please log in again."
            self.objectWillChange.send()
        }
    }
    
    @objc private func handleRepairerReauthenticationRequired() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("🔐 Repairer authentication expired - reauthentication required")
            self.needsReauthentication = true
            self.connectionState = .authError
            self.errorMessage = "Authentication expired. Please log in again."
            self.objectWillChange.send()
        }
    }
    
    // MARK: - Public Methods
    
    func loadChat(forBookingId bookingId: Int) {
        self.bookingId = bookingId
        self.connectionAttempts = 0
        isLoading = true
        errorMessage = nil
        connectionState = .connecting
        
        print("Loading chat for booking #\(bookingId)")
        
        // Check if we have auth tokens before trying to load
        if AuthNetworkService.shared.getRepairerToken() == nil && AuthNetworkService.shared.getToken() == nil {
            isLoading = false
            errorMessage = "Authentication required: Please log in to access chat"
            connectionState = .error
            print("❌ Error: No authentication token available")
            return
        }
        
        // Connect to WebSocket first - don't wait for message loading to succeed
        // This ensures real-time messages work even if history fails to load
        chatService.connectToChat(bookingId: bookingId)
        
        // Add a connection verification check
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self, self.bookingId == bookingId else { return }
            
            // Force UI update to show connection status
            if self.chatService.isConnected() {
                print("✅ WebSocket connection verified")
                self.connectionState = .connected
                self.objectWillChange.send()
            } else {
                print("⚠️ WebSocket connection not verified, attempting reconnect")
                self.connectionState = .reconnecting
                self.objectWillChange.send()
                self.retryConnection(bookingId: bookingId)
            }
        }
        
        // Schedule reconnection check to ensure WebSocket reliability
        scheduleReconnectionCheck(bookingId: bookingId)
        
        // Load message history
        loadMessageHistory(bookingId: bookingId)
    }
    
    private func loadMessageHistory(bookingId: Int) {
        chatService.getMessages(bookingId: bookingId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self, self.bookingId == bookingId else { return }
                
                self.isLoading = false
                
                switch result {
                case .success(let messages):
                    print("Successfully loaded \(messages.count) messages")
                    
                    // Debug: Print the first message to verify its format
                    if let firstMessage = messages.first {
                        print("First message: id=\(firstMessage.id), content=\"\(firstMessage.content)\"")
                        print("Sender: type=\(firstMessage.sender_type), id=\(firstMessage.sender_id)")
                        print("Sender info: \(String(describing: firstMessage.sender_info))")
                    }
                    
                    self.messages = messages.sorted(by: { $0.created_at < $1.created_at })
                    
                    // Force UI update
                    self.objectWillChange.send()
                    
                    // Call the callback with the new message count
                    let count = self.messages.count
                    self.onMessagesUpdated?(count)
                    
                case .failure(let error):
                    if case .unauthorized = error {
                        self.errorMessage = "Authentication error: Unable to access chat history. Tap to retry."
                        print("⚠️ Auth error loading messages, but WebSocket may still work: \(error)")
                        
                        // Try to reconnect WebSocket with the other token
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            (self.chatService as? ChatNetworkService)?.reconnectToChat(bookingId: bookingId)
                        }
                    } else {
                        self.errorMessage = "Failed to load message history. Tap to retry."
                        print("⚠️ Error loading messages, but WebSocket may still work: \(error)")
                    }
                    
                    // Force UI update
                    self.objectWillChange.send()
                }
            }
        }
    }
    
    private func retryConnection(bookingId: Int) {
        connectionAttempts += 1
        
        if connectionAttempts <= maxConnectionAttempts {
            print("🔄 Retry attempt \(connectionAttempts) of \(maxConnectionAttempts)")
            connectionState = .reconnecting
            
            // Disconnect and reconnect
            chatService.disconnectFromChat()
            
            // Wait a moment before reconnecting
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self, self.bookingId == bookingId else { return }
                
                // Try connecting again
                self.chatService.connectToChat(bookingId: bookingId)
                
                // Retry loading messages
                self.loadMessageHistory(bookingId: bookingId)
                
                // Check connection state after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    guard let self = self, self.bookingId == bookingId else { return }
                    
                    if self.chatService.isConnected() {
                        self.connectionState = .connected
                        self.objectWillChange.send()
                    } else if self.connectionAttempts < self.maxConnectionAttempts {
                        self.retryConnection(bookingId: bookingId)
                    } else {
                        self.connectionState = .error
                        self.errorMessage = "Failed to connect after multiple attempts. Tap to retry."
                        self.objectWillChange.send()
                    }
                }
            }
        } else {
            connectionState = .error
            errorMessage = "Connection failed after \(maxConnectionAttempts) attempts. Tap to retry."
            objectWillChange.send()
        }
    }
    
    // Method to handle retry taps
    func retryConnection() {
        guard let bookingId = self.bookingId else { return }
        
        print("🔄 Manual retry requested")
        connectionAttempts = 0
        isLoading = true
        errorMessage = nil
        connectionState = .connecting
        
        // Force UI update
        objectWillChange.send()
        
        // Retry connection
        chatService.disconnectFromChat()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.loadChat(forBookingId: bookingId)
        }
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
                    self?.objectWillChange.send()
                }
            }
        }
    }
    
    func disconnect() {
        chatService.disconnectFromChat()
        connectionState = .disconnected
    }
    
    // MARK: - ChatMessageDelegate
    
    func didReceiveMessage(_ message: Message, forBookingId: Int) {
        // Only process messages for the current booking
        guard forBookingId == bookingId else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Add the message to our array
            self.messages.append(message)
            
            // Force UI update
            self.objectWillChange.send()
            
            // Call the callback with the new message count
            let count = self.messages.count
            self.onMessagesUpdated?(count)
            
            // Schedule notification if app is in background
            if UIApplication.shared.applicationState == .background {
                NotificationManager.shared.scheduleMessageNotification(message: message)
            }
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