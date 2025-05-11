//
//  MessageBubble.swift
//  Applicare-UI
//
//

import SwiftUI

struct MessageBubble: View {
    let message: Message
    let isFromCurrentUser: Bool
    
    var body: some View {
        VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 6) {
            // Show sender name for other person's messages
            if !isFromCurrentUser {
                Text(message.displayName)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
            }
            
            HStack {
                if isFromCurrentUser {
                    Spacer()
                }
                
                Text(message.content)
                    .padding(12)
                    .background(isFromCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(isFromCurrentUser ? .white : .primary)
                    .cornerRadius(16)
                    .padding(.horizontal, 8)
                
                if !isFromCurrentUser {
                    Spacer()
                }
            }
            
            Text(message.formattedTime)
                .font(.caption2)
                .foregroundColor(.gray)
                .padding(.horizontal, 8)
        }
        .padding(.vertical, 4)
    }
}

struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        let currentUserMessage = Message(
            id: 1,
            content: "Hello! This is a message from the current user.",
            sender_type: "User",
            sender_id: 123,
            sender_name: "Current User",
            created_at: "2023-08-01T12:34:56.789Z"
        )
        
        let otherUserMessage = Message(
            id: 2,
            content: "Hi there! This is a response from another user.",
            sender_type: "Repairer",
            sender_id: 456,
            sender_name: "Other User",
            created_at: "2023-08-01T12:36:56.789Z"
        )
        
        VStack {
            MessageBubble(message: currentUserMessage, isFromCurrentUser: true)
            MessageBubble(message: otherUserMessage, isFromCurrentUser: false)
        }
        .padding()
    }
} 