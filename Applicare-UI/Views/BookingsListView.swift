//
//  BookingsListView.swift
//  Applicare-UI
//

import SwiftUI

struct BookingsListView: View {
    @StateObject private var viewModel = BookingsViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                // Header
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Bookings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.leading)
                    
                    if viewModel.bookings.isEmpty && !viewModel.isLoading {
                        HStack {
                            Spacer()
                            
                            VStack(spacing: 20) {
                                Image(systemName: "calendar.badge.clock")
                                    .font(.system(size: 70))
                                    .foregroundColor(.gray.opacity(0.7))
                                
                                Text("No bookings yet")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                Text("Your bookings will appear here")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 80)
                            
                            Spacer()
                        }
                    } else {
                        // Bookings list
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.bookings) { booking in
                                    NavigationLink(destination: SimpleChatView(
                                        booking: booking,
                                        contactName: viewModel.repairerName(for: booking)
                                    )) {
                                        BookingCardContent(
                                            booking: booking,
                                            repairerName: viewModel.repairerName(for: booking),
                                            formattedDate: viewModel.formatDate(dateString: booking.start_time),
                                            formattedTime: viewModel.formatTime(dateString: booking.start_time),
                                            statusColor: viewModel.statusColor(for: booking.status)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .onAppear {
                                        print("NavigationLink for Booking #\(booking.id) appeared")
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
                
                Spacer()
            }
            
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            }
            
            if let errorMessage = viewModel.errorMessage {
                VStack {
                    Spacer()
                    
                    Text(errorMessage)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                        .padding()
                    
                    Spacer().frame(height: 50)
                }
            }
        }
        .navigationTitle("Bookings")
        .onAppear {
            viewModel.loadBookings()
        }
    }
}

// Separate content view for the booking card to use within NavigationLink
struct BookingCardContent: View {
    let booking: Booking
    let repairerName: String
    let formattedDate: String
    let formattedTime: String
    let statusColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(repairerName)
                        .font(.headline)
                    
                    Text("Booking #\(booking.id)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Status indicator
                HStack {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    
                    Text(booking.status.capitalized)
                        .font(.caption)
                        .foregroundColor(statusColor)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(statusColor.opacity(0.1))
                .cornerRadius(12)
            }
            
            Divider()
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    Label {
                        Text(formattedDate)
                            .font(.subheadline)
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                    }
                    
                    Label {
                        Text(formattedTime)
                            .font(.subheadline)
                    } icon: {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                // Message icon with "Chat" text
                HStack {
                    Text("Chat")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                    
                    Image(systemName: "message.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            
            if let notes = booking.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
}

struct BookingsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BookingsListView()
        }
    }
} 