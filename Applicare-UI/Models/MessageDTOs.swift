//
//  MessageDTOs.swift
//  Applicare-UI
//

import Foundation

// Request DTO for sending a new message
struct SendMessageRequestDTO: Codable {
    let message: MessageContent
    let booking_id: Int
    
    struct MessageContent: Codable {
        let content: String
    }
}

// WebSocket message format for sending
struct WebSocketSendMessage: Codable {
    let command: String = "message"
    let identifier: String
    let data: String
    
    // Define coding keys to exclude command from decoding
    private enum CodingKeys: String, CodingKey {
        case identifier, data
    }
    
    // Helper initializer to create a properly formatted WebSocket message
    static func create(bookingId: Int, content: String) -> WebSocketSendMessage? {
        // Create encodable structs instead of dictionaries
        struct ChatIdentifier: Codable {
            let channel: String
            let booking_id: Int
        }
        
        struct ChatData: Codable {
            let action: String
            let content: String
        }
        
        let identifier = ChatIdentifier(channel: "ChatChannel", booking_id: bookingId)
        let data = ChatData(action: "receive", content: content)
        
        guard let identifierData = try? JSONEncoder().encode(identifier),
              let identifierString = String(data: identifierData, encoding: .utf8),
              let dataData = try? JSONEncoder().encode(data),
              let dataString = String(data: dataData, encoding: .utf8) else {
            return nil
        }
        
        return WebSocketSendMessage(identifier: identifierString, data: dataString)
    }
}

// WebSocket subscription format
struct WebSocketSubscription: Codable {
    let command: String = "subscribe"
    let identifier: String
    
    // Define coding keys to exclude command from decoding
    private enum CodingKeys: String, CodingKey {
        case identifier
    }
    
    // Helper initializer to create a properly formatted subscription message
    static func create(bookingId: Int) -> WebSocketSubscription? {
        // Create an encodable struct instead of a dictionary
        struct ChatIdentifier: Codable {
            let channel: String
            let booking_id: Int
        }
        
        let identifier = ChatIdentifier(channel: "ChatChannel", booking_id: bookingId)
        
        guard let identifierData = try? JSONEncoder().encode(identifier),
              let identifierString = String(data: identifierData, encoding: .utf8) else {
            return nil
        }
        
        return WebSocketSubscription(identifier: identifierString)
    }
}

// WebSocket received message format
struct WebSocketReceivedMessage: Codable {
    let identifier: String
    let message: Message?
    
    // Helper function to parse the booking ID from the identifier
    func getBookingId() -> Int? {
        guard let data = identifier.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let bookingId = json["booking_id"] as? Int else {
            return nil
        }
        return bookingId
    }
} 