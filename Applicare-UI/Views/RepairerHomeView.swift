import SwiftUI

struct RepairerHomeView: View {
    @EnvironmentObject var repairerAuthViewModel: RepairerAuthViewModel
    @State private var showSettings = false
    @State private var bookings: [Booking] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var filterStatus: String? = nil
    @State private var showingAddNoteSheet = false
    @State private var showingChatSheet = false
    @State private var selectedBookingId: Int? = nil
    @State private var selectedBooking: Booking? = nil
    @State private var noteText: String = ""
    @State private var navigateToChat = false
    
    private let bookingService = BookingNetworkService.shared
    
    // Date range filters with default to current month
    @State private var startDate: Date = {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        return calendar.date(from: components) ?? Date()
    }()
    
    @State private var endDate: Date = {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        var endComponents = DateComponents()
        endComponents.month = 1
        endComponents.day = -1
        return calendar.date(byAdding: endComponents, to: calendar.date(from: components) ?? Date()) ?? Date()
    }()
    
    var filterOptions: [String?] = [nil, "pending", "confirmed", "completed", "cancelled"]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Header with welcome and menu
                HStack {
                    if let repairer = repairerAuthViewModel.currentRepairer {
                        Text("Welcome, \(repairer.name)!")
                            .font(.largeTitle)
                    } else {
                        Text("Welcome!")
                            .font(.largeTitle)
                    }
                    Spacer()
                    Menu {
                        Button(action: {
                            showSettings = true
                        }) {
                            Label("Edit Profile", systemImage: "person.crop.circle")
                        }
                        
                        Button(action: {
                            repairerAuthViewModel.logout()
                        }) {
                            Label("Logout", systemImage: "arrow.right.square")
                                .foregroundColor(.red)
                        }
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                    }
                }
                .padding(.bottom)
                
                // Filters section
                VStack(alignment: .leading) {
                    Text("Filters")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    // Status filter
                    HStack {
                        Text("Status:")
                            .foregroundColor(.secondary)
                        
                        Picker("Status", selection: $filterStatus) {
                            Text("All").tag(nil as String?)
                            Text("Pending").tag("pending" as String?)
                            Text("Confirmed").tag("confirmed" as String?)
                            Text("Completed").tag("completed" as String?)
                            Text("Cancelled").tag("cancelled" as String?)
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    // Date range filter (simplified UI)
                    HStack {
                        Text("Date Range:")
                            .foregroundColor(.secondary)
                        
                        DatePicker("", selection: $startDate, displayedComponents: .date)
                            .labelsHidden()
                        
                        Text("to")
                            .foregroundColor(.secondary)
                        
                        DatePicker("", selection: $endDate, displayedComponents: .date)
                            .labelsHidden()
                    }
                    
                    // Apply filters button
                    Button(action: {
                        loadBookings()
                    }) {
                        Text("Apply Filters")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Content area
                if isLoading {
                    Spacer()
                    ProgressView()
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else if let error = errorMessage {
                    Spacer()
                    Text(error)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else if bookings.isEmpty {
                    Spacer()
                    Text("No bookings found")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    List {
                        ForEach(bookings) { booking in
                            BookingRow(
                                booking: booking, 
                                onAddNote: {
                                    selectedBookingId = booking.id
                                    // Pre-populate with existing repairer notes if available
                                    if let existingNotes = booking.repairer_note {
                                        noteText = existingNotes
                                    } else {
                                        noteText = ""
                                    }
                                    showingAddNoteSheet = true
                                }, 
                                onOpenChat: {
                                    selectedBooking = booking
                                    print("Setting selectedBooking to #\(booking.id)")
                                    navigateToChat = true
                                    print("Set navigateToChat to true")
                                },
                                onRowTap: {
                                    // Open full booking details instead of just add note
                                    selectedBooking = booking
                                    if let existingNotes = booking.repairer_note {
                                        noteText = existingNotes
                                    } else {
                                        noteText = ""
                                    }
                                    // Future enhancement: Show detailed booking view instead
                                }
                            )
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .swipeActions(edge: .trailing) {
                                if booking.status.lowercased() == "pending" {
                                    // Accept button
                                    Button {
                                        updateBookingStatus(id: booking.id, status: "confirmed")
                                    } label: {
                                        Label("Accept", systemImage: "checkmark")
                                    }
                                    .tint(.green)
                                    
                                    // Reject button
                                    Button {
                                        updateBookingStatus(id: booking.id, status: "cancelled")
                                    } label: {
                                        Label("Reject", systemImage: "xmark")
                                    }
                                    .tint(.red)
                                } else if booking.status.lowercased() == "confirmed" {
                                    // Complete button
                                    Button {
                                        updateBookingStatus(id: booking.id, status: "completed")
                                    } label: {
                                        Label("Complete", systemImage: "checkmark.circle")
                                    }
                                    .tint(.blue)
                                }
                            }
                            .swipeActions(edge: .leading) {
                                // Add note button
                                Button {
                                    selectedBookingId = booking.id
                                    // Pre-populate with existing repairer notes if available
                                    if let existingNotes = booking.repairer_note {
                                        noteText = existingNotes
                                    } else {
                                        noteText = ""
                                    }
                                    showingAddNoteSheet = true
                                } label: {
                                    Label("Add Note", systemImage: "square.and.pencil")
                                }
                                .tint(.orange)
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddNoteSheet) {
                // Add repairer note sheet
                VStack(alignment: .leading, spacing: 20) {
                    Text(noteText.isEmpty ? "Add Repairer Note" : "Update Repairer Note")
                        .font(.headline)
                    
                    Text("Add your professional notes about this booking. These notes are only visible to you and other repairers.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $noteText)
                        .frame(minHeight: 100)
                        .padding(4)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    HStack {
                        Button("Cancel") {
                            noteText = ""
                            showingAddNoteSheet = false
                        }
                        
                        Spacer()
                        
                        Button("Save") {
                            if let id = selectedBookingId, !noteText.isEmpty {
                                addRepairerNote(id: id, note: noteText)
                            }
                            noteText = ""
                            showingAddNoteSheet = false
                        }
                        .disabled(noteText.isEmpty)
                    }
                }
                .padding()
            }
            .background(
                NavigationLink(
                    destination: Group {
                        if let booking = selectedBooking {
                            ChatView(
                                booking: booking,
                                contactName: booking.customerName,
                                isRepairer: true // Mark as repairer mode
                            )
                        }
                    },
                    isActive: $navigateToChat
                ) {
                    EmptyView()
                }
            )
            .onChange(of: navigateToChat) { _, newValue in
                print("navigateToChat changed to: \(newValue)")
                if !newValue {
                    print("Returned from chat view")
                }
            }
        }
        .onAppear {
            print("RepairerHomeView appeared")
            loadBookings()
        }
    }
    
    // Format dates for API
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func loadBookings() {
        isLoading = true
        errorMessage = nil
        
        // Check if we have any authentication token
        if !AuthNetworkService.shared.isRepairerLoggedIn() && !AuthNetworkService.shared.isUserLoggedIn() {
            self.errorMessage = "Authentication error: You are not logged in"
            self.isLoading = false
            return
        }
        
        // Debug: Print token information
        if let token = AuthNetworkService.shared.getRepairerToken() ?? AuthNetworkService.shared.getToken() {
            print("🔐 Using authentication token: \(token)")
        } else {
            print("⚠️ No authentication token found")
        }
        
        // Format dates for API
        let startDateString = formatDate(startDate)
        let endDateString = formatDate(endDate)
        
        bookingService.getRepairerBookings(status: filterStatus, startDate: startDateString, endDate: endDateString) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let bookings):
                    self.bookings = bookings
                case .failure(let error):
                    self.errorMessage = "Failed to load bookings: \(error.localizedDescription)"
                    print("🛑 Error loading bookings: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateBookingStatus(id: Int, status: String) {
        isLoading = true
        
        bookingService.updateRepairerBookingStatus(id: id, status: status) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success:
                    // Reload bookings to get updated status
                    self.loadBookings()
                case .failure(let error):
                    self.errorMessage = "Failed to update booking: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func addRepairerNote(id: Int, note: String) {
        isLoading = true
        
        bookingService.addRepairerBookingNote(id: id, note: note) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success:
                    // Reload bookings to get updated note
                    self.loadBookings()
                case .failure(let error):
                    self.errorMessage = "Failed to add repairer note: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct BookingRow: View {
    let booking: Booking
    var onAddNote: () -> Void
    var onOpenChat: () -> Void
    var onRowTap: () -> Void
    
    var body: some View {
        ZStack {
            // This transparent background captures the row tap
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .onTapGesture {
                    onRowTap()
                }
            
            // The actual row content
            VStack(alignment: .leading, spacing: 8) {
                // Add customer name
                HStack {
                    Text("Booking #\(booking.id)")
                        .font(.headline)
                    
                    Spacer()
                    
                    // Status indicator
                    Text(booking.status)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(statusColor(booking.status))
                        .cornerRadius(4)
                }
                
                // Customer name - now using direct property from booking
                Text("Customer: \(booking.customerName)")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Text("Date: \(formatDate(booking.start_time))")
                    .font(.subheadline)
                
                Text("Address: \(booking.address)")
                    .font(.subheadline)
                
                if let notes = booking.notes, !notes.isEmpty {
                    Text("Customer Notes: \(notes)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                
                if let repairerNote = booking.repairer_note, !repairerNote.isEmpty {
                    Text("Your Notes: \(repairerNote)")
                        .font(.caption)
                        .foregroundColor(.green)
                        .lineLimit(3)
                }
                
                // Action buttons
                HStack {
                    Spacer()
                    
                    // Add Note Button
                    Button(action: onAddNote) {
                        Label("Repairer Notes", systemImage: "note.text")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(5)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .allowsHitTesting(true)
                    
                    Spacer()
                        .frame(width: 10)
                    
                    // Open Chat Button
                    Button(action: {
                        print("Chat button tapped for booking #\(booking.id)")
                        onOpenChat()
                    }) {
                        Label("Chat", systemImage: "message")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(5)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .allowsHitTesting(true)
                    
                    Spacer()
                }
                .padding(.top, 5)
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.white, Color(.systemGray6)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
    }
    
    private func statusColor(_ status: String) -> Color {
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
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
            return formatter.string(from: date)
        }
        return dateString
    }
}

#Preview {
    RepairerHomeView()
        .environmentObject(RepairerAuthViewModel())
} 