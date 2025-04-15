import SwiftUI

struct RepairerBookingView: View {
    @State private var selectedDate: Date?
    @State private var selectedTime: String?
    @State private var selectedPlace: String
    @State private var currentMonth: Date

    let repairer: Repairer
    
    let availability: [Int: Int]

    let timeSlots = ["7:00 AM", "7:30 AM", "8:00 AM", "9:00 AM", "9:30 AM", "10:00 AM"]
    let placeOptions = ["At home", "Repair Shop"]

    init(repairer: Repairer) {
        self.repairer = repairer
        _selectedDate = State(initialValue: nil)
        _selectedTime = State(initialValue: nil)
        _selectedPlace = State(initialValue: placeOptions[0])
        _currentMonth = State(initialValue: Date())

        self.availability = [8: 1, 10: 2, 12: 1, 14: 1, 20: 2, 23: 1]
    }

    init() {
        self.init(repairer: Repairer.singleDummy)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                RepairerInfoView(repairer: repairer)

                CalendarView(
                    currentMonth: $currentMonth,
                    selectedDate: $selectedDate,
                    availability: availability
                )

                TimeSelectionView(
                    selectedTime: $selectedTime,
                    timeSlots: timeSlots
                )

                PlaceSelectionView(
                    selectedPlace: $selectedPlace,
                    placeOptions: placeOptions
                )

                Spacer()

            }
            .padding()
        }
        .navigationTitle("Booking")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(action: {
            // Handle share action
        }) {
            Image(systemName: "square.and.arrow.up")
                .foregroundColor(.primary)
        })
        .safeAreaInset(edge: .bottom) {
             Button(action: {
                 print("Booking details for Repairer ID: \(repairer.id)")
                 print("Date: \(selectedDate?.formatted(date: .long, time: .omitted) ?? "Not selected")")
                 print("Time: \(selectedTime ?? "Not selected")")
                 print("Place: \(selectedPlace)")
             }) {
                 Text("Book")
                     .fontWeight(.semibold)
                     .frame(maxWidth: .infinity)
                     .padding()
                     .background(Color.blue)
                     .foregroundColor(.white)
                     .cornerRadius(10)
             }
             .padding(.horizontal)
             .padding(.bottom)
             .background(.thinMaterial)
        }
    }
}

struct RepairerInfoView: View {
    let repairer: Repairer
    
    var body: some View {
        NavigationLink(destination: RepairerProfileView(repairer: repairer)) {
            HStack(spacing: 15) {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay(Image(systemName: "person.fill").resizable().scaledToFit().scaleEffect(0.5).foregroundColor(.gray))

                VStack(alignment: .leading) {
                    HStack {
                        Text(repairer.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Text("Professional")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                    }
                    Text(repairer.title)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.gray)
                            .font(.caption)
                        Text("123 Main St, Anytown") // Placeholder address
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 2)
                }
            }
            .foregroundColor(.primary)
        }
    }
}

struct CalendarView: View {
    @Binding var currentMonth: Date
    @Binding var selectedDate: Date?
    let availability: [Int: Int]

    let daysOfWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text(monthYearString(from: currentMonth))
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Button { changeMonth(by: -1) } label: { Image(systemName: "chevron.left") }
                Button { changeMonth(by: 1) } label: { Image(systemName: "chevron.right") }
            }
            .padding(.horizontal, 5)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(daysInMonth(for: currentMonth), id: \.self) { date in
                    if let date = date {
                        DayView(
                            date: date,
                            isSelected: isSameDay(date, selectedDate),
                            availability: availability[Calendar.current.component(.day, from: date)] ?? 0,
                            action: {
                                selectedDate = date
                            }
                        )
                    } else {
                        Rectangle().fill(Color.clear)
                    }
                }
            }

            HStack(spacing: 20) {
                Spacer()
                LegendItem(color: Color.yellow.opacity(0.3), text: "Quite busy")
                LegendItem(color: Color.red.opacity(0.3), text: "Very busy")
            }
             .padding(.top, 5)
             .padding(.trailing)

        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(15)
    }

    func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    func changeMonth(by amount: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: amount, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    func daysInMonth(for date: Date) -> [Date?] {
        var dates: [Date?] = []
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let monthFirstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }

        let firstDayWeekday = calendar.component(.weekday, from: monthFirstDay)

        for _ in 1..<firstDayWeekday {
            dates.append(nil)
        }

        for day in range {
            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: monthFirstDay) {
                dates.append(dayDate)
            }
        }
        return dates
    }

    func isSameDay(_ date1: Date, _ date2: Date?) -> Bool {
        guard let date2 = date2 else { return false }
        return Calendar.current.isDate(date1, inSameDayAs: date2)
    }
}

struct DayView: View {
    let date: Date
    let isSelected: Bool
    let availability: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(Calendar.current.component(.day, from: date))")
                .frame(maxWidth: .infinity)
                .frame(height: 35)
                .foregroundColor(foregroundColor())
                .background(backgroundView())
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func backgroundView() -> some View {
        if isSelected {
            Color.blue
        } else {
            switch availability {
            case 1: Color.yellow.opacity(0.3)
            case 2: Color.red.opacity(0.3)
            default: Color.clear
            }
        }
    }

     private func foregroundColor() -> Color {
        if isSelected {
            return .white
        } else {
            return .primary
        }
    }
}


struct LegendItem: View {
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 5) {
            Rectangle()
                .fill(color)
                .frame(width: 15, height: 15)
                .cornerRadius(3)
            Text(text)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}


struct TimeSelectionView: View {
    @Binding var selectedTime: String?
    let timeSlots: [String]
    let columns = [GridItem(.adaptive(minimum: 100, maximum: 120))]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Time")
                .font(.title3)
                .fontWeight(.semibold)

            LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                 ForEach(timeSlots, id: \.self) { time in
                    Button(action: { selectedTime = time }) {
                        Text(time)
                            .font(.footnote)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity)
                            .background(selectedTime == time ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                            .foregroundColor(selectedTime == time ? .blue : .primary)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedTime == time ? Color.blue : Color.clear, lineWidth: 1)
                            )
                    }
                     .buttonStyle(.plain)
                }
            }
        }
    }
}

struct PlaceSelectionView: View {
    @Binding var selectedPlace: String
    let placeOptions: [String]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Place")
                .font(.title3)
                .fontWeight(.semibold)

            Picker("Select Place", selection: $selectedPlace) {
                ForEach(placeOptions, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.menu)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)


            /*
            HStack {
                Text(selectedPlace)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .onTapGesture {
                // Add action to show place selection options (e.g., ActionSheet)
            }
            */
        }
    }
}


struct RepairerBookingView_Previews: PreviewProvider {
    static var previews: some View {
        RepairerBookingView()
    }
} 