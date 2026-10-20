import Foundation
import UserNotifications

enum NotificationManager {
    static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    static func schedule(for habit: Habit) {
        guard let time = habit.reminderTime else { return }
        let cal = Calendar.current
        let comps = cal.dateComponents([.hour, .minute], from: time)
        let content = UNMutableNotificationContent()
        content.title = "Hábito pendiente"
        content.body = habit.name
        content.sound = .default
        var dateComps = DateComponents()
        dateComps.hour = comps.hour
        dateComps.minute = comps.minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComps, repeats: true)
        let request = UNNotificationRequest(identifier: habit.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func cancel(for habit: Habit) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habit.id.uuidString])
    }

    static func rescheduleAll(_ habits: [Habit]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        habits.forEach { schedule(for: $0) }
    }
}
