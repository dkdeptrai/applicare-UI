//
//  RepairerChatButton.swift
//  Applicare-UI
//

import SwiftUI

struct RepairerChatButton: View {
    let booking: Booking
    let customerName: String
    @State private var showChat = false
    
    var body: some View {
        Button(action: {
            showChat = true
        }) {
            HStack {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                Text("Chat with Customer")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(20)
        }
        .sheet(isPresented: $showChat) {
            RepairerChatView(booking: booking, customerName: customerName)
        }
    }
}

struct RepairerChatIconButton: View {
    let booking: Booking
    let customerName: String
    @State private var showChat = false
    
    var body: some View {
        Button(action: {
            showChat = true
        }) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .foregroundColor(.white)
                .padding(10)
                .background(Color.blue)
                .clipShape(Circle())
        }
        .sheet(isPresented: $showChat) {
            RepairerChatView(booking: booking, customerName: customerName)
        }
    }
}

struct RepairerChatButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            RepairerChatButton(
                booking: Booking.sampleBooking(),
                customerName: "John Smith"
            )
            
            RepairerChatIconButton(
                booking: Booking.sampleBooking(),
                customerName: "John Smith"
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 