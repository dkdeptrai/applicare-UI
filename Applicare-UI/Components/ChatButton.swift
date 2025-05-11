//
//  ChatButton.swift
//  Applicare-UI
//
//

import SwiftUI

struct ChatButton: View {
    let booking: Booking
    let contactName: String
    @State private var showChat = false
    
    var body: some View {
        Button(action: {
            showChat = true
        }) {
            HStack {
                Image(systemName: "message.fill")
                Text("Chat")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(20)
        }
        .sheet(isPresented: $showChat) {
            NavigationView {
                ChatView(booking: booking, contactName: contactName)
                    .navigationBarItems(trailing: Button(action: {
                        showChat = false
                    }) {
                        Text("Close")
                    })
            }
        }
    }
}

struct ChatButtonSmall: View {
    let booking: Booking
    let contactName: String
    @State private var showChat = false
    
    var body: some View {
        Button(action: {
            showChat = true
        }) {
            Image(systemName: "message.fill")
                .foregroundColor(.white)
                .padding(10)
                .background(Color.blue)
                .clipShape(Circle())
        }
        .sheet(isPresented: $showChat) {
            NavigationView {
                ChatView(booking: booking, contactName: contactName)
                    .navigationBarItems(trailing: Button(action: {
                        showChat = false
                    }) {
                        Text("Close")
                    })
            }
        }
    }
}

struct ChatButton_Previews: PreviewProvider {
    static var previews: some View {
        let sampleBooking = Booking(
            id: 1,
            repairer_id: 123,
            service_id: 456,
            start_time: "2023-08-01T10:00:00.000Z",
            end_time: "2023-08-01T12:00:00.000Z",
            status: "confirmed",
            address: "123 Main St",
            notes: nil,
            created_at: "2023-07-25T09:30:00.000Z",
            updated_at: "2023-07-25T09:30:00.000Z"
        )
        
        VStack {
            ChatButton(booking: sampleBooking, contactName: "John Doe")
            ChatButtonSmall(booking: sampleBooking, contactName: "John Doe")
        }
        .padding()
    }
} 