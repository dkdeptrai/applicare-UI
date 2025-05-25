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
                            LazyVStack(spacing: 24) {
                                ForEach(viewModel.bookings) { booking in
                                    NavigationLink(destination: SimpleChatView(
                                        booking: booking,
                                        contactName: booking.customerName
                                    )) {
                                        BookingCardContent(
                                            booking: booking,
                                            repairerName: viewModel.repairerName(for: booking),
                                            formattedDate: viewModel.formatDate(dateString: booking.start_time),
                                            formattedTime: viewModel.formatTime(dateString: booking.start_time),
                                            statusColor: viewModel.statusColor(for: booking.status),
                                            showChat: true,
                                            onChat: nil
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

struct BookingsListView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = BookingsViewModel()
        
        NavigationView {
            BookingsListView()
                .environmentObject(viewModel)
        }
    }
} 
