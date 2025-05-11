//
//  ChatNetworkService.swift
//  Applicare-UI
//

import Foundation

protocol ChatNetworkServiceProtocol {
    // API methods
    func getMessages(bookingId: Int, completion: @escaping (Result<[Message], NetworkError>) -> Void)
    func sendMessage(bookingId: Int, content: String, completion: @escaping (Result<Void, NetworkError>) -> Void)
    
    // WebSocket methods
    func connectToChat(bookingId: Int)
    func disconnectFromChat()
    func isConnected() -> Bool
    
    // Message delegate
    var messageDelegate: ChatMessageDelegate? { get set }
}

// Protocol for message reception delegate
protocol ChatMessageDelegate: AnyObject {
    func didReceiveMessage(_ message: Message, forBookingId: Int)
}

class ChatNetworkService: NSObject, ChatNetworkServiceProtocol {
    static let shared = ChatNetworkService()
    
    private let networkService: NetworkServiceProtocol
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession!
    private var currentBookingId: Int?
    
    weak var messageDelegate: ChatMessageDelegate?
    
    private init(networkService: NetworkServiceProtocol = BaseNetworkService.shared) {
        self.networkService = networkService
        super.init()
        urlSession = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
    }
    
    // MARK: - API Methods
    
    func getMessages(bookingId: Int, completion: @escaping (Result<[Message], NetworkError>) -> Void) {
        print("⚡️ Fetching messages for booking #\(bookingId) from URL: \(APIEndpoint.getMessages(bookingId: bookingId).urlString)")
        
        // Use URLSession directly for debugging
        guard let url = URL(string: APIEndpoint.getMessages(bookingId: bookingId).urlString) else {
            print("❌ Invalid URL")
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = AuthNetworkService.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("✅ Using token: \(token)")
        } else {
            print("❌ No auth token available")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(.requestFailed))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response")
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }
            
            print("📡 Response status code: \(httpResponse.statusCode)")
            
            if !(200...299).contains(httpResponse.statusCode) {
                print("❌ Error status code: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError(statusCode: httpResponse.statusCode, message: nil)))
                }
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                DispatchQueue.main.async {
                    completion(.failure(.requestFailed))
                }
                return
            }
            
            // Print raw JSON for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Raw JSON response: \(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                let messages = try decoder.decode([Message].self, from: data)
                print("✅ Successfully decoded \(messages.count) messages")
                
                DispatchQueue.main.async {
                    completion(.success(messages))
                }
            } catch {
                print("❌ Decoding error: \(error)")
                
                DispatchQueue.main.async {
                    completion(.failure(.decodingFailed))
                }
            }
        }.resume()
    }
    
    func sendMessage(bookingId: Int, content: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        let requestDTO = SendMessageRequestDTO(
            message: SendMessageRequestDTO.MessageContent(content: content),
            booking_id: bookingId
        )
        networkService.request(APIEndpoint.sendMessage, body: requestDTO, completion: completion)
    }
    
    // MARK: - WebSocket Methods
    
    func connectToChat(bookingId: Int) {
        // Save booking ID for subscription
        self.currentBookingId = bookingId
        
        // Get auth token
        guard let token = AuthNetworkService.shared.getToken() else {
            print("❌ Error: No auth token available for WebSocket connection")
            return
        }
        
        // Create WebSocket URL
        let serverURL = APIEndpoint.baseURL.replacingOccurrences(of: "http://", with: "ws://")
                                        .replacingOccurrences(of: "https://", with: "wss://")
        let wsURL = URL(string: "\(serverURL)/cable?token=\(token)")!
        
        print("🔌 Connecting to WebSocket at \(wsURL)")
        
        // Create a WebSocket task
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: wsURL)
        
        // Start receiving messages
        receiveMessage()
        
        // Connect to the WebSocket server
        webSocketTask?.resume()
        
        // Subscribe to the channel after a short delay to ensure connection is established
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.subscribeToChannel(bookingId: bookingId)
            self.ping() // Start ping cycle
        }
    }
    
    func disconnectFromChat() {
        print("🔌 Disconnecting from WebSocket")
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        currentBookingId = nil
    }
    
    // Check if the WebSocket is connected
    func isConnected() -> Bool {
        return webSocketTask != nil
    }
    
    // MARK: - Private WebSocket Helper Methods
    
    private func subscribeToChannel(bookingId: Int) {
        print("🔌 Attempting to subscribe to chat channel for booking #\(bookingId)")
        
        // Create a JSON object for the identifier
        let identifierDict: [String: Any] = [
            "channel": "ChatChannel",
            "booking_id": bookingId
        ]
        
        // Convert identifier to JSON string
        guard let identifierData = try? JSONSerialization.data(withJSONObject: identifierDict),
              let identifierString = String(data: identifierData, encoding: .utf8) else {
            print("❌ Failed to create identifier JSON")
            return
        }
        
        // Create the subscription message
        let subscriptionDict: [String: String] = [
            "command": "subscribe",
            "identifier": identifierString
        ]
        
        // Convert subscription to JSON string
        guard let subscriptionData = try? JSONSerialization.data(withJSONObject: subscriptionDict),
              let subscriptionString = String(data: subscriptionData, encoding: .utf8) else {
            print("❌ Failed to create subscription JSON")
            return
        }
        
        print("📤 Sending subscription: \(subscriptionString)")
        
        // Send the subscription message
        webSocketTask?.send(.string(subscriptionString)) { error in
            if let error = error {
                print("❌ Failed to subscribe: \(error)")
            } else {
                print("✅ Subscription request sent successfully")
            }
        }
        
        // Send a ping after a delay to keep the connection alive
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.ping()
        }
    }
    
    private func ping() {
        // Only ping if we're still connected and have a booking ID
        guard let webSocketTask = webSocketTask, 
              isConnected(),
              currentBookingId != nil else {
            print("⚠️ Cannot ping - WebSocket not connected or no active booking")
            return
        }
        
        print("🏓 Sending ping")
        
        // Send ping message
        let pingMessage = "{\"command\":\"ping\",\"identifier\":\"ping\"}"
        webSocketTask.send(.string(pingMessage)) { [weak self] error in
            if let error = error {
                print("❌ Ping failed: \(error)")
                // If ping fails, try to reconnect
                if let self = self, let bookingId = self.currentBookingId {
                    DispatchQueue.main.async {
                        self.reconnectToChat(bookingId: bookingId)
                    }
                }
                return
            }
            
            // Schedule next ping only if successful and still connected
            if let self = self {
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    // Double-check we're still connected before scheduling next ping
                    guard self.isConnected() && self.currentBookingId != nil else { return }
                    self.ping()
                }
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                // Process the received message
                switch message {
                case .string(let text):
                    print("📥 RAW WEBSOCKET MESSAGE: \(text)")
                    self.handleReceivedMessage(text)
                    
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        print("📥 RAW WEBSOCKET BINARY: \(text)")
                        self.handleReceivedMessage(text)
                    } else {
                        print("❌ Received WebSocket binary data but couldn't convert to string")
                    }
                    
                @unknown default:
                    print("❌ Received unknown WebSocket message type")
                }
                
                // Continue listening for more messages
                if self.isConnected() {
                    self.receiveMessage()
                }
                
            case .failure(let error):
                print("❌ WebSocket receive error: \(error)")
                
                // If the task was cancelled or connection lost, don't try to reconnect here
                if (error as NSError).domain == NSURLErrorDomain && 
                   (error as NSError).code == NSURLErrorCancelled {
                    print("⚠️ WebSocket task was cancelled - not attempting to reconnect")
                    return
                }
                
                // Otherwise, try to reconnect
                if let bookingId = self.currentBookingId {
                    print("🔄 Connection lost - attempting to reconnect in 3 seconds")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.reconnectToChat(bookingId: bookingId)
                    }
                }
            }
        }
    }
    
    // Helper method to get the current booking ID from an identifier
    private func getCurrentBookingId() -> Int? {
        guard let task = webSocketTask,
              let url = task.currentRequest?.url,
              let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = urlComponents.queryItems,
              let bookingIdString = queryItems.first(where: { $0.name == "booking_id" })?.value,
              let bookingId = Int(bookingIdString) else {
            return nil
        }
        return bookingId
    }
    
    private func handleReceivedMessage(_ message: String) {
        print("⚠️ DEBUGGING MESSAGE HANDLING ⚠️")
        print("📥 Processing message: \(message)")
        
        // Parse the message JSON
        guard let data = message.data(using: .utf8) else {
            print("❌ Failed to convert message to data")
            return
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("❌ Failed to parse message JSON")
            return
        }
        
        print("📋 Parsed JSON: \(json)")
        
        // Handle subscription confirmation
        if let type = json["type"] as? String, type == "confirm_subscription" {
            print("✅ Subscription confirmed")
            return
        }
        
        // Handle ping messages
        if json["type"] as? String == "ping" {
            print("🏓 Received ping")
            return
        }
        
        // Extract the message data
        print("🔍 Extracting message data from: \(json)")
        
        // Try to extract the message from various possible structures
        if let messageData = extractMessageData(from: json) {
            print("✅ Successfully extracted message data: \(messageData)")
            
            // Debug: Print all keys in messageData
            print("📊 Message data keys: \(messageData.keys.joined(separator: ", "))")
            
            // Create a Message object
            if let id = messageData["id"] as? Int,
               let content = messageData["content"] as? String,
               let senderType = messageData["sender_type"] as? String,
               let senderId = messageData["sender_id"] as? Int,
               let createdAt = messageData["created_at"] as? String {
                
                print("✅ Required fields found: id, content, sender_type, sender_id, created_at")
                
                // Get booking_id from message or from identifier
                let bookingId = messageData["booking_id"] as? Int ?? 
                                self.extractBookingIdFromIdentifier(identifierString: json["identifier"] as? String)
                
                // Handle both sender_name and sender_info formats
                let senderName = messageData["sender_name"] as? String
                let senderInfo = messageData["sender_info"] as? [String: Any]
                
                print("📊 Sender details: name=\(senderName ?? "nil"), info=\(senderInfo ?? [:])")
                
                guard let bookingId = bookingId else {
                    print("❌ Could not determine booking_id from message")
                    return
                }
                
                // Create the message object
                let message = Message(
                    id: id,
                    content: content,
                    sender_type: senderType,
                    sender_id: senderId,
                    sender_name: senderName,
                    sender_info: senderInfo,
                    created_at: createdAt,
                    booking_id: bookingId
                )
                
                print("📲 Created message object: id=\(id), content=\(content)")
                print("📲 Sender: type=\(senderType), id=\(senderId), name=\(message.displayName)")
                print("📲 Will notify delegate for booking #\(bookingId)")
                
                // Notify delegate
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { 
                        print("❌ Self was deallocated before notifying delegate")
                        return 
                    }
                    
                    if let delegate = self.messageDelegate {
                        print("📲 Calling delegate method didReceiveMessage")
                        delegate.didReceiveMessage(message, forBookingId: bookingId)
                    } else {
                        print("❌ Message delegate is nil - cannot deliver message")
                    }
                }
            } else {
                print("❌ Missing required fields in message data")
                print("📊 Available fields: \(messageData.keys.joined(separator: ", "))")
            }
        } else {
            print("❌ Could not extract message data from WebSocket message")
        }
    }
    
    private func extractMessageData(from json: [String: Any]) -> [String: Any]? {
        // Try different possible message formats
        print("🔍 Attempting to extract message data from JSON: \(json)")
        
        // Format 1: {message: {...}}
        if let message = json["message"] as? [String: Any] {
            print("✅ Format 1 matched: direct message")
            return message
        }
        
        // Format 2: {identifier: "...", message: {...}}
        if let message = json["message"] as? [String: Any],
           let identifier = json["identifier"] as? String {
            print("✅ Format 2 matched: message with identifier: \(identifier)")
            return message
        }
        
        // Format 3: {identifier: "...", message: {message: {...}}}
        if let outerMessage = json["message"] as? [String: Any],
           let innerMessage = outerMessage["message"] as? [String: Any] {
            print("✅ Format 3 matched: nested message")
            return innerMessage
        }
        
        // Format 4: Parse identifier for booking_id and add it to message
        if let message = json["message"] as? [String: Any],
           let identifierString = json["identifier"] as? String {
            print("✅ Format 4 matched: message with identifier to parse")
            
            if let identifierData = identifierString.data(using: .utf8),
               let identifierJSON = try? JSONSerialization.jsonObject(with: identifierData) as? [String: Any],
               let bookingId = identifierJSON["booking_id"] as? Int {
                
                var messageWithBookingId = message
                messageWithBookingId["booking_id"] = bookingId
                return messageWithBookingId
            } else {
                print("❌ Failed to parse identifier: \(identifierString)")
            }
        }
        
        print("❌ No matching format found for message")
        return nil
    }
    
    // Helper to extract booking ID from channel identifier
    private func extractBookingIdFromIdentifier(identifierString: String?) -> Int? {
        guard let identifierString = identifierString,
              let data = identifierString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let bookingId = json["booking_id"] as? Int else {
            return nil
        }
        return bookingId
    }
    
    // MARK: - Send Message via WebSocket
    
    func sendMessageViaWebSocket(content: String, bookingId: Int) {
        guard isConnected() else {
            print("❌ Cannot send message - WebSocket not connected")
            // Try to reconnect
            self.connectToChat(bookingId: bookingId)
            return
        }
        
        print("📤 Sending message via WebSocket: \"\(content)\" to booking #\(bookingId)")
        
        // Create identifier JSON
        let identifierDict: [String: Any] = [
            "channel": "ChatChannel",
            "booking_id": bookingId
        ]
        
        // Convert identifier to JSON string
        guard let identifierData = try? JSONSerialization.data(withJSONObject: identifierDict),
              let identifierString = String(data: identifierData, encoding: .utf8) else {
            print("❌ Failed to create identifier JSON")
            return
        }
        
        // Create message data according to API docs
        let messageData: [String: Any] = [
            "content": content
        ]
        
        // Convert data to JSON string
        guard let messageDataJson = try? JSONSerialization.data(withJSONObject: messageData),
              let messageDataString = String(data: messageDataJson, encoding: .utf8) else {
            print("❌ Failed to create message data JSON")
            return
        }
        
        // Create the complete message
        let messageDict: [String: Any] = [
            "command": "message",
            "identifier": identifierString,
            "data": messageDataString
        ]
        
        // Convert to JSON string
        guard let messageJSON = try? JSONSerialization.data(withJSONObject: messageDict),
              let messageString = String(data: messageJSON, encoding: .utf8) else {
            print("❌ Failed to create message JSON")
            return
        }
        
        print("📤 Formatted message: \(messageString)")
        
        // Send the message
        webSocketTask?.send(.string(messageString)) { error in
            if let error = error {
                print("❌ Failed to send message: \(error)")
            } else {
                print("✅ Message sent successfully")
            }
        }
    }
    
    // Force reconnection to the chat channel
    func reconnectToChat(bookingId: Int) {
        print("🔄 Forcing WebSocket reconnection for booking #\(bookingId)")
        
        // Disconnect first
        self.disconnectFromChat()
        
        // Wait a moment before reconnecting
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.connectToChat(bookingId: bookingId)
        }
    }
} 