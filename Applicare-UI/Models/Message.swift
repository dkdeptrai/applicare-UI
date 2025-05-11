//
//  Message.swift
//  Applicare-UI
//

import Foundation

struct Message: Codable, Identifiable, Hashable {
    let id: Int
    let content: String
    let sender_type: String
    let sender_id: Int
    let created_at: String
    let booking_id: Int?
    
    // API returns sender_info, not sender_name
    let sender_info: SenderInfo?
    
    struct SenderInfo: Codable, Hashable {
        let id: Int
        let name: String
        let type: String
    }
    
    // Get the sender name from sender_info
    var displayName: String {
        if let info = sender_info {
            return info.name
        }
        return sender_type == "User" ? "You" : "Repairer"
    }
    
    // Computed property to determine if the message is from the current user
    func isFromCurrentUser() -> Bool {
        if let currentUserId = AuthNetworkService.shared.getUserId(),
           sender_type == "User" && sender_id == currentUserId {
            return true
        }
        
        // Check if the current user is a repairer
        if let currentRepairerId = AuthNetworkService.shared.getRepairerId(),
           sender_type == "Repairer" && sender_id == currentRepairerId {
            return true
        }
        
        return false
    }
    
    // Determine if message is from a repairer (for repairer chat view)
    func isFromRepairer() -> Bool {
        return sender_type == "Repairer"
    }
    
    // Computed property to format the date/time
    var formattedTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from: created_at) {
            let timeFormatter = DateFormatter()
            timeFormatter.timeZone = TimeZone.current
            timeFormatter.dateFormat = "h:mm a"
            return timeFormatter.string(from: date)
        }
        return ""
    }
    
    // Ensure Message can be decoded even if fields are missing
    enum CodingKeys: String, CodingKey {
        case id, content, sender_type, sender_id, created_at, sender_info, booking_id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        sender_type = try container.decode(String.self, forKey: .sender_type)
        sender_id = try container.decode(Int.self, forKey: .sender_id)
        created_at = try container.decode(String.self, forKey: .created_at)
        booking_id = try container.decode(Int?.self, forKey: .booking_id)
        
        // Optional fields
        sender_info = try container.decodeIfPresent(SenderInfo.self, forKey: .sender_info)
    }
    
    // Custom initializer for manual creation and testing
    init(id: Int, content: String, sender_type: String, sender_id: Int, sender_name: String? = nil, sender_info: [String: Any]? = nil, created_at: String, booking_id: Int? = nil) {
        self.id = id
        self.content = content
        self.sender_type = sender_type
        self.sender_id = sender_id
        
        // Create sender_info from provided data
        if let senderInfo = sender_info {
            // Try to convert dictionary to SenderInfo
            if let senderInfoId = senderInfo["id"] as? Int,
               let senderInfoName = senderInfo["name"] as? String,
               let senderInfoType = senderInfo["type"] as? String {
                self.sender_info = SenderInfo(id: senderInfoId, name: senderInfoName, type: senderInfoType)
            } else {
                // Fallback to creating from sender_id and sender_type
                self.sender_info = SenderInfo(id: sender_id, name: sender_name ?? sender_type, type: sender_type)
            }
        } else if let name = sender_name {
            // Create from sender_name if provided
            self.sender_info = SenderInfo(id: sender_id, name: name, type: sender_type)
        } else {
            // Create default sender_info
            self.sender_info = SenderInfo(id: sender_id, name: sender_type, type: sender_type)
        }
        
        self.created_at = created_at
        self.booking_id = booking_id
    }
} 