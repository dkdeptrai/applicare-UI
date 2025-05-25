//
//  HomeView.swift
//  Applicare-UI
//

import SwiftUI

// Temporary Home View
struct HomeView: View {
    // Inject the AuthViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var applianceViewModel = ApplianceViewModel()
    @StateObject private var bookingsViewModel = BookingsViewModel()
    // State to control presenting the settings sheet
    @State private var showSettings = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // User info
                        HStack(alignment: .center, spacing: 16) {
                            Image("avatar_placeholder") // Replace with real avatar if available
                                .resizable()
                                .frame(width: 56, height: 56)
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hi, \(authViewModel.currentUser?.name ?? "User")!")
                                    .font(.title2).fontWeight(.bold)
                                HStack(spacing: 4) {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundColor(.blue)
                                    Text(authViewModel.currentUser?.address ?? "No address")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            Image(systemName: "bell")
                                .font(.title2)
                                .foregroundColor(Color.blue)
                        }
                        // Appliances section
                        HStack {
                            Text("Your appliances")
                                .font(.title3).fontWeight(.bold)
                            Spacer()
                            Button(action: {/* Add new appliance */}) {
                                Text("Add new")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        if applianceViewModel.appliances.isEmpty {
                            VStack(alignment: .center, spacing: 8) {
                                Image(systemName: "wrench.and.screwdriver")
                                    .resizable()
                                    .frame(width: 48, height: 48)
                                    .foregroundColor(.gray.opacity(0.4))
                                Text("No appliances yet. Add your first appliance!")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(applianceViewModel.appliances) { appliance in
                                        NavigationLink(destination: ApplianceDetailView(
                                            appliance: appliance,
                                            onBack: { /* Navigation will handle back */ },
                                            onFindRepairer: { /* TODO: Implement find repairer */ }
                                        )) {
                                            ApplianceCard(appliance: appliance)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        // Find the next upcoming booking (future date, not DONE/CANCELLED)
                        let now = Date()
                        let upcomingBooking = bookingsViewModel.bookings.first(where: { booking in
                            let formatter = ISO8601DateFormatter()
                            if let date = formatter.date(from: booking.start_time) {
                                return date > now && booking.status != "DONE" && booking.status != "CANCELLED"
                            }
                            return false
                        })
                        // Upcoming Schedules section
                        Text("Upcoming Schedules")
                            .font(.title3).fontWeight(.bold)
                        if let upcoming = upcomingBooking {
                            BookingCardContent(
                                booking: upcoming,
                                repairerName: bookingsViewModel.repairerName(for: upcoming),
                                formattedDate: bookingsViewModel.formatDate(dateString: upcoming.start_time),
                                formattedTime: bookingsViewModel.formatTime(dateString: upcoming.start_time),
                                statusColor: bookingsViewModel.statusColor(for: upcoming.status),
                                showChat: false,
                                onChat: nil
                            )
                        } else {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(.systemGray6))
                                .frame(height: 120)
                                .overlay(Text("No upcoming schedules").foregroundColor(.gray))
                        }
                        // Booking history
                        HStack {
                            Text("Booking history")
                                .font(.title3).fontWeight(.bold)
                            Spacer()
                            Button(action: {/* New booking */}) {
                                Text("New booking")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        let maxHistory = 5
                        let showSeeAll = bookingsViewModel.bookings.count > maxHistory
                        let bookingsForHistory = bookingsViewModel.bookings.count > 1 ? Array(bookingsViewModel.bookings.dropFirst()) : bookingsViewModel.bookings
                        let displayedBookings = Array(bookingsForHistory.prefix(maxHistory))
                        if bookingsForHistory.isEmpty {
                            VStack(alignment: .center, spacing: 8) {
                                Image(systemName: "calendar.badge.plus")
                                    .resizable()
                                    .frame(width: 48, height: 48)
                                    .foregroundColor(.gray.opacity(0.4))
                                Text("No bookings yet. Book a service to get started!")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        } else {
                            VStack(spacing: 16) {
                                ForEach(displayedBookings, id: \.id) { booking in
                                    NavigationLink(destination: SimpleChatView(booking: booking, contactName: booking.customerName)) {
                                        BookingCardContent(
                                            booking: booking,
                                            repairerName: bookingsViewModel.repairerName(for: booking),
                                            formattedDate: bookingsViewModel.formatDate(dateString: booking.start_time),
                                            formattedTime: bookingsViewModel.formatTime(dateString: booking.start_time),
                                            statusColor: bookingsViewModel.statusColor(for: booking.status),
                                            showChat: false,
                                            onChat: nil
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                if showSeeAll {
                                    NavigationLink(destination: BookingsListView()) {
                                        Text("See all")
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.bottom, 80)
                        }
                    }
                    .padding([.horizontal, .top])
                }
                // Bottom navigation bar
                HomeTabBar()
                    .padding(.bottom, 0)
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear {
                if authViewModel.isAuthenticated && authViewModel.currentUser == nil {
                    authViewModel.fetchProfileData()
                }
                applianceViewModel.loadMyAppliances()
                bookingsViewModel.loadBookings()
            }
            .sheet(isPresented: $showSettings) {
                ProfileSettingsView().environmentObject(authViewModel)
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - UpcomingScheduleCard
struct UpcomingScheduleCard: View {
    let booking: Booking
    
    private let statuses: [String] = ["PENDING", "CONFIRMED", "COMING", "DONE"]
    
    var currentStatus: String {
        booking.status.uppercased()
    }
    
    func icon(for status: String) -> some View {
        switch status {
        case "PENDING":
            // Use a loading animation or ProgressView
            return AnyView(ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .blue)).frame(width: 24, height: 24))
        case "CONFIRMED":
            return AnyView(Image("confirmed").resizable().frame(width: 24, height: 24))
        case "COMING":
            return AnyView(Image("coming").resizable().frame(width: 24, height: 24))
        case "DONE":
            return AnyView(Image("done").resizable().frame(width: 24, height: 24))
        default:
            return AnyView(EmptyView())
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image("avatar_placeholder")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text("Mr. Ricardo") // Replace with real repairer name
                        .font(.headline)
                        .foregroundColor(.white)
                    HStack(spacing: 4) {
                        Text("5 km - 4.5")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
                Spacer()
                Button(action: {/* Call action */}) {
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }
            }
            .padding(.bottom, 4)
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundColor(.white)
                    Text("Mon, 20 December") // Format from booking.start_time
                        .foregroundColor(.white)
                }
                Spacer()
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .foregroundColor(.white)
                    Text("8:00 AM") // Format from booking.start_time
                        .foregroundColor(.white)
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(Color.white.opacity(0.15))
            .cornerRadius(10)
            HStack {
                Spacer()
                ForEach(statuses, id: \.self) { status in
                    let isCurrent = status == currentStatus
                    VStack(spacing: 4) {
                        icon(for: status)
                            .opacity(isCurrent ? 1.0 : 0.3)
                        Text(status.capitalized)
                            .font(.caption2)
                            .fontWeight(isCurrent ? .bold : .regular)
                            .foregroundColor(.white)
                            .opacity(isCurrent ? 1.0 : 0.5)
                    }
                    Spacer(minLength: 0)
                }
                Spacer()
            }
        }
        .padding()
        .background(Color.blue)
        .cornerRadius(18)
        .shadow(color: Color(.black).opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

// MARK: - HomeTabBar
struct HomeTabBar: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab: Int = 0
    var body: some View {
        HStack(spacing: 0) {
            tabItem(icon: "house.fill", label: "Home", selected: selectedTab == 0) { selectedTab = 0 }
            tabItem(icon: "safari", label: "Explore", selected: selectedTab == 1) { selectedTab = 1 }
            tabItem(icon: "bubble.left.and.bubble.right.fill", label: "Chat", selected: selectedTab == 2) { selectedTab = 2 }
            NavigationLink(destination: MenuView().environmentObject(authViewModel)) {
                VStack {
                    Image(systemName: "square.grid.2x2")
                    Text("Menu").font(.caption2)
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(selectedTab == 3 ? .blue : .blue.opacity(0.7))
            }
            .simultaneousGesture(TapGesture().onEnded { selectedTab = 3 })
        }
        .padding(.vertical, 10)
        .background(Color.white.ignoresSafeArea(edges: .bottom))
        .shadow(color: Color(.black).opacity(0.08), radius: 8, x: 0, y: -2)
    }
    @ViewBuilder
    private func tabItem(icon: String, label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        VStack {
            Image(systemName: icon)
            Text(label).font(.caption2)
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(selected ? .blue : .blue.opacity(0.7))
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide a dummy AuthViewModel for the preview
        let previewAuthViewModel = AuthViewModel()
        // Optionally set a dummy user for previewing the logged-in state
        previewAuthViewModel.currentUser = User(
            id: 1, 
            name: "Preview User", 
            emailAddress: "preview@example.com", 
            address: "123 Preview St", 
            latitude: 10.0, 
            longitude: 106.0, 
            dateOfBirth: "1990-01-01",
            mobileNumber: "+1234567890",
            onboarded: true,
            createdAt: "", 
            updatedAt: ""
        )
        previewAuthViewModel.isAuthenticated = true

        return HomeView()
            .environmentObject(previewAuthViewModel)
    }
} 