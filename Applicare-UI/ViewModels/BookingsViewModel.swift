//
//  BookingsViewModel.swift
//  Applicare-UI
//

import Foundation
import SwiftUI

class BookingsViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let bookingService: BookingNetworkService
    
    init(bookingService: BookingNetworkService = BookingNetworkService.shared) {
        self.bookingService = bookingService
        loadBookings()
    }
    
    func loadBookings() {
        isLoading = true
        errorMessage = nil
        
        bookingService.getAllBookings { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let bookings):
                    self?.bookings = bookings
                case .failure(let error):
                    self?.errorMessage = "Failed to load bookings: \(error.localizedDescription)"
                    print("Error loading bookings: \(error)")
                }
            }
        }
    }
    
    // Get repairer name - in a real app, you would fetch this from a proper source
    func repairerName(for booking: Booking) -> String {
        if let repairer = booking.repairer {
            return repairer.name
        }
        return "Repairer #\(booking.repairer_id)"
    }
    
    // Format booking date
    func formatDate(dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "EEE, dd MMMM"
            return displayFormatter.string(from: date)
        }
        return "Unknown date"
    }
    
    // Format booking time
    func formatTime(dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from: dateString) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            return timeFormatter.string(from: date)
        }
        return "Unknown time"
    }
    
    // Get color for a booking status
    func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "pending":
            return .orange
        case "confirmed":
            return .green
        case "completed":
            return .blue
        case "cancelled":
            return .red
        default:
            return .gray
        }
    }
} 