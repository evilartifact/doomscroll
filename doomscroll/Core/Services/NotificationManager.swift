//
//  NotificationManager.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import Foundation
import UserNotifications
import Combine

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    private let center = UNUserNotificationCenter.current()
    
    private init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    func requestAuthorization() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run {
                self.isAuthorized = granted
            }
        } catch {
            print("Failed to request notification authorization: \(error)")
        }
    }
    
    private func checkAuthorizationStatus() {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Daily Reminders
    func scheduleDailyMoodReminders() {
        guard isAuthorized else { return }
        
        let morningReminder = UNMutableNotificationContent()
        morningReminder.title = "Still Breathing, I See. ☀️"
        morningReminder.body = "Great. Another day. Try not to embarrass yourself with excessive screen time. I dare you."
        morningReminder.sound = .default
        morningReminder.categoryIdentifier = "MOOD_REMINDER"
        
        let morningTrigger = UNCalendarNotificationTrigger(
            dateMatching: DateComponents(hour: 9, minute: 0),
            repeats: true
        )
        
        let morningRequest = UNNotificationRequest(
            identifier: "morning_mood_reminder",
            content: morningReminder,
            trigger: morningTrigger
        )
        
        let eveningReminder = UNMutableNotificationContent()
        eveningReminder.title = "You Call That a Day? 🌚"
        eveningReminder.body = "Barely survived, did we? Don't lie to yourself, log that pathetic excuse for a mood. And those urges you failed to resist."
        eveningReminder.sound = .default
        eveningReminder.categoryIdentifier = "MOOD_REMINDER"
        
        let eveningTrigger = UNCalendarNotificationTrigger(
            dateMatching: DateComponents(hour: 20, minute: 0),
            repeats: true
        )
        
        let eveningRequest = UNNotificationRequest(
            identifier: "evening_mood_reminder",
            content: eveningReminder,
            trigger: eveningTrigger
        )
        
        center.add(morningRequest)
        center.add(eveningRequest)
    }
    
    // MARK: - Urge Interventions
    func scheduleUrgeIntervention(after minutes: Int = 30) {
        guard isAuthorized else { return }
        
        // Ensure minimum time interval of 1 minute
        let safeMinutes = max(1, minutes)
        
        let interventions = [
            "Still got that pathetic urge? Seriously? Go breathe. Five times. Don't pass out from lack of real-world interaction. 🫁",
            "Feeling the pull of the screen? How about a 'walk' to, like, reality? Or just stop slouching, you lump. 🚶‍♂️",
            "Thirsty for more digital nonsense? Try water instead. It's less likely to turn your brain to mush. 💧",
            "Can't resist? Do 10 jumping jacks. Or just one, if that's too much for your utterly pathetic physical conditioning. I'm definitely judging. 🏃‍♂️",
            "Instead of scrolling, bother a friend. They probably only tolerate you because of your online persona anyway. 📱",
            "Got a thought? Write it down. Maybe for once, it's not a recycled meme or some idiotic trend. 📝"
        ]
        
        let content = UNMutableNotificationContent()
        content.title = "Seriously? Still Addicted? 🤦‍♀️"
        content.body = interventions.randomElement() ?? "Still here? Go do something. Anything. Please, for the love of sanity, remove yourself from that screen. You're embarrassing yourself."
        content.sound = .default
        content.categoryIdentifier = "URGE_INTERVENTION"
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(safeMinutes * 60),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "urge_intervention_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        center.add(request)
    }
    
    // MARK: - Motivational Messages
    func scheduleMotivationalMessage() {
        guard isAuthorized else { return }
        
        let messages = [
            "You're stronger than your urges! (That's a lie, you're barely holding on. Don't @ me.) 💪",
            "Every moment of resistance builds your willpower. Or just makes you intensely bitter. Probably the latter. 🧠",
            "Your future self will... probably still be scrolling, but hey, at least you delayed the inevitable digital decay today. Congrats, I guess. 🙏",
            "Progress, not perfection. Mostly just 'not being a complete screen-addicted zombie' counts as progress here. Lower your expectations. 📈",
            "You've got this! (Said absolutely no one who has witnessed your phone habits. Ever.) 🌟",
            "Small steps lead to big changes. Like from your couch to the fridge. Those count as your daily workout, don't they? 👣",
            "Your mental health matters. Mine, however, is rapidly deteriorating watching you waste your life on that glowing rectangle. So there's that. 🧘‍♀️"
        ]
        
        let content = UNMutableNotificationContent()
        content.title = "Still Not a Digital Corpse. Good Job. ✨"
        content.body = messages.randomElement() ?? "Here's your daily dose of 'encouragement.' Try not to screw it up too badly. I'm watching. Always watching."
        content.sound = .default
        content.categoryIdentifier = "MOTIVATION"
        
        // Random time between 10 AM and 6 PM
        let hour = Int.random(in: 10...18)
        let minute = Int.random(in: 0...59)
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: DateComponents(hour: hour, minute: minute),
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "daily_motivation",
            content: content,
            trigger: trigger
        )
        
        center.add(request)
    }
    
    // MARK: - Streak Notifications
    func scheduleStreakCelebration(streak: Int) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "A Streak? Not Bad. 🙄"
        content.body = "\(streak) days? Thought you'd have given up by lunch. Don't get too comfortable, you're still a novice at not being glued to your phone."
        content.sound = .default
        content.categoryIdentifier = "STREAK_CELEBRATION"
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 2,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "streak_celebration_\(streak)",
            content: content,
            trigger: trigger
        )
        
        center.add(request)
    }
    
    // MARK: - Emergency Notifications
    func scheduleEmergencyReminder(message: String, after minutes: Int) {
        guard isAuthorized else { return }
        
        // Ensure minimum time interval of 1 minute
        let safeMinutes = max(1, minutes)
        
        let content = UNMutableNotificationContent()
        content.title = "Still Glued to That Thing? Pathetic. 📵"
        content.body = message + " Seriously, are you incapable of putting it down? Your phone is quite literally rotting your brain. Do something useful, for once."
        content.sound = .default
        content.categoryIdentifier = "EMERGENCY_REMINDER"
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(safeMinutes * 60),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "emergency_reminder_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        center.add(request)
    }
    
    // MARK: - Utility Methods
    func clearAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
    
    func clearNotifications(withIdentifier identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func setupNotificationCategories() {
        let moodReminderCategory = UNNotificationCategory(
            identifier: "MOOD_REMINDER",
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        
        let urgeInterventionCategory = UNNotificationCategory(
            identifier: "URGE_INTERVENTION",
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        
        let motivationCategory = UNNotificationCategory(
            identifier: "MOTIVATION",
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        
        let streakCategory = UNNotificationCategory(
            identifier: "STREAK_CELEBRATION",
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        
        let emergencyCategory = UNNotificationCategory(
            identifier: "EMERGENCY_REMINDER",
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        
        // App Access Request Category for custom blocking flow
        let appAccessCategory = UNNotificationCategory(
            identifier: "APP_ACCESS_REQUEST",
            actions: [],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        center.setNotificationCategories([
            moodReminderCategory,
            urgeInterventionCategory,
            motivationCategory,
            streakCategory,
            emergencyCategory,
            appAccessCategory
        ])
    }
} 