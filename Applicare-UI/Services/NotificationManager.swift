import UserNotifications
import SwiftUI

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted {
                    print("✅ Notification permission granted")
                } else if let error = error {
                    print("❌ Notification permission error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func scheduleNotification(title: String, body: String, timeInterval: TimeInterval = 5) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("✅ Notification scheduled successfully")
            }
        }
    }
    
    func scheduleBookingReminder(booking: Booking) {
        // Schedule reminder 1 hour before booking
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        guard let bookingDate = dateFormatter.date(from: booking.start_time) else {
            print("❌ Invalid booking date format")
            return
        }
        
        // Calculate time interval for 1 hour before booking
        let reminderDate = bookingDate.addingTimeInterval(-3600) // 1 hour before
        let timeInterval = reminderDate.timeIntervalSinceNow
        
        // Only schedule if the reminder time is in the future
        if timeInterval > 0 {
            let content = UNMutableNotificationContent()
            content.title = "Upcoming Booking Reminder"
            content.body = "You have a booking with \(booking.customerName) in 1 hour"
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            let request = UNNotificationRequest(
                identifier: "booking-\(booking.id)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Error scheduling booking reminder: \(error.localizedDescription)")
                } else {
                    print("✅ Booking reminder scheduled for \(reminderDate)")
                }
            }
        }
    }
    
    func scheduleMessageNotification(message: Message) {
        let content = UNMutableNotificationContent()
        content.title = "New Message"
        content.body = "\(message.displayName): \(message.content)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "message-\(message.id)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling message notification: \(error.localizedDescription)")
            } else {
                print("✅ Message notification scheduled")
            }
        }
    }
    
    func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("✅ All pending notifications removed")
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
    
    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification tap here
        print("📱 Notification tapped: \(response.notification.request.identifier)")
        completionHandler()
    }
} 