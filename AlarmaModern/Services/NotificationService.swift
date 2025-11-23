//
//  NotificationService.swift
//  AlarmaModern
//
//  Schedule actual notifications for alarms
//

import Foundation
import UserNotifications

@MainActor
final class NotificationService {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()

    // Schedule notification for an alarm
    func scheduleNotification(for alarm: Alarm) async throws {
        // Request permission first
        let authorized = try await requestAuthorization()
        guard authorized else {
            throw NotificationError.notAuthorized
        }

        // Cancel existing notification if any
        center.removePendingNotificationRequests(withIdentifiers: [alarm.id.uuidString])

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = alarm.group?.name ?? "Alarm"
        content.body = "Time to wake up!"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(alarm.sound.rawValue).mp3"))
        content.categoryIdentifier = "ALARM_CATEGORY"

        // Create trigger based on repeat pattern
        if alarm.repeatDays.isEmpty {
            // One-time alarm
            let components = Calendar.current.dateComponents([.hour, .minute], from: alarm.time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            let request = UNNotificationRequest(
                identifier: alarm.id.uuidString,
                content: content,
                trigger: trigger
            )
            try await center.add(request)
        } else {
            // Recurring alarm - schedule for each day
            for weekday in alarm.repeatDays {
                var components = Calendar.current.dateComponents([.hour, .minute], from: alarm.time)
                components.weekday = weekday.rawValue

                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

                let request = UNNotificationRequest(
                    identifier: "\(alarm.id.uuidString)-\(weekday.rawValue)",
                    content: content,
                    trigger: trigger
                )
                try await center.add(request)
            }
        }
    }

    // Cancel notification for an alarm
    func cancelNotification(for alarm: Alarm) {
        if alarm.repeatDays.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: [alarm.id.uuidString])
        } else {
            let identifiers = alarm.repeatDays.map { "\(alarm.id.uuidString)-\($0.rawValue)" }
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }

    // Request notification permission
    private func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    // Setup notification actions (Snooze, Dismiss)
    func setupNotificationCategories() {
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze 5 min",
            options: []
        )

        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Dismiss",
            options: [.destructive]
        )

        let alarmCategory = UNNotificationCategory(
            identifier: "ALARM_CATEGORY",
            actions: [snoozeAction, dismissAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        center.setNotificationCategories([alarmCategory])
    }
}

enum NotificationError: Error, LocalizedError {
    case notAuthorized
    case schedulingFailed

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Notification permission not granted"
        case .schedulingFailed:
            return "Failed to schedule notification"
        }
    }
}

// MARK: - Notification Delegate
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {

    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }

    // Handle user interaction with notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        switch response.actionIdentifier {
        case "SNOOZE_ACTION":
            await handleSnooze(for: response.notification)
        case "DISMISS_ACTION":
            // Just dismiss
            break
        default:
            // Opened the notification
            break
        }
    }

    private func handleSnooze(for notification: UNNotification) async {
        // Schedule another notification 5 minutes from now
        let content = notification.request.content.mutableCopy() as! UNMutableNotificationContent

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 300, repeats: false) // 5 min

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        try? await UNUserNotificationCenter.current().add(request)
    }
}
