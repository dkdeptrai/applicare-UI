import SwiftUI

struct ApplianceDetailView: View {
    let appliance: Appliance
    let onBack: () -> Void
    let onFindRepairer: () -> Void
    @StateObject private var viewModel = ApplianceDetailViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                Color(red: 0.7, green: 0.95, blue: 1.0)
                    .frame(height: 260)
                    .edgesIgnoringSafeArea(.top)
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.black)
                                .padding(12)
                                .background(Color.white.opacity(0.7))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.leading, 16)
                    .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0 + 16)
                    
                    HStack {
                        Spacer()
                        if let url = URL(string: appliance.image_url ?? "") {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFit()
                            } placeholder: {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 180, height: 180)
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 220, height: 220)
                            
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 180, height: 180)
                                .foregroundColor(.gray)
                                
                        }
                        Spacer()
                    }
                }
            }
            .frame(height: 260)
            .clipped()
            VStack(alignment: .leading, spacing: 16) {
                // Appliance info
                Text(appliance.name)
                    .font(.title)
                    .fontWeight(.bold)
                HStack {
                    Text("Brand:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(appliance.brand)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    Spacer()
                    if let price = appliance.model as? String, !price.isEmpty {
                        Text("Price:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("\(price)$")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                if let createdAt = appliance.created_at.split(separator: "T").first {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Guarantee")
                            .font(.headline)
                        HStack(spacing: 24) {
                            HStack(spacing: 8) {
                                Image(systemName: "clock")
                                    .foregroundColor(.blue)
                                Text("2 year") // If you have real guarantee data, use it here
                                    .font(.subheadline)
                            }
                            HStack(spacing: 8) {
                                Image(systemName: "calendar")
                                    .foregroundColor(.blue)
                                Text(String(createdAt))
                                    .font(.subheadline)
                            }
                            HStack(spacing: 8) {
                                Image(systemName: "calendar.badge.clock")
                                    .foregroundColor(.red)
                                Text(guaranteeEndDate(from: String(createdAt)))
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                Divider()
                Text("Repair History")
                    .font(.headline)
                if viewModel.isLoading {
                    ProgressView()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                } else if viewModel.repairHistory.isEmpty {
                    Text("No repair history for this appliance.")
                        .foregroundColor(.gray)
                } else {
                    VStack(spacing: 12) {
                        ForEach(viewModel.repairHistory, id: \ .id) { booking in
                            BookingCardContent(
                                booking: booking,
                                repairerName: booking.repairer?.name ?? "Repairer",
                                formattedDate: formatDate(booking.start_time),
                                formattedTime: formatTime(booking.start_time),
                                statusColor: .blue, // Or use a helper if needed
                                showChat: false,
                                onChat: nil
                            )
                        }
                    }
                }
                Spacer(minLength: 0)
                Button(action: onFindRepairer) {
                    Text("Find repairer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.top, 16)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.white)
                    .shadow(color: Color(.black).opacity(0.05), radius: 8, x: 0, y: -2)
            )
            .offset(y: -32)
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            viewModel.loadRepairHistory(for: appliance.id)
        }
    }
    func formatDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: iso) {
            let display = DateFormatter()
            display.dateFormat = "yyyy-MM-dd"
            return display.string(from: date)
        }
        return iso
    }
    func formatTime(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: iso) {
            let display = DateFormatter()
            display.dateFormat = "h:mm a"
            return display.string(from: date)
        }
        return ""
    }
    func guaranteeEndDate(from start: String) -> String {
        // Add 2 years to the start date for guarantee end (replace with real logic if available)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: start) {
            if let endDate = Calendar.current.date(byAdding: .year, value: 2, to: date) {
                return formatter.string(from: endDate)
            }
        }
        return ""
    }
} 