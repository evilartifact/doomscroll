//
//  CustomBlockingScreenView.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import SwiftUI

struct CustomBlockingScreenView: View {
    @State private var showingPushNotificationFlow = false
    @State private var showingRewardScreen = false
    @StateObject private var levelManager = LevelManager.shared
    
    let appName: String
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("App Blocked")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("You're trying to access \(appName)")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    DSButton(
                        "Continue",
                        style: .warning,
                        size: .medium
                    ) {
                        showingPushNotificationFlow = true
                    }
                    
                    DSButton(
                        "Change My Mind",
                        style: .success,
                        size: .medium
                    ) {
                        showingRewardScreen = true
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .padding()
        }
        .dsSheet(title: "Continue to App", isPresented: $showingPushNotificationFlow) {
            PushNotificationFlowView(isPresented: $showingPushNotificationFlow, appName: appName)
        }
        .dsSheet(title: "Great Choice!", isPresented: $showingRewardScreen) {
            RewardScreenView(isPresented: $showingRewardScreen, source: .blockingScreen)
        }
    }
}

struct PushNotificationFlowView: View {
    @Binding var isPresented: Bool
    @State private var showingNotificationSettings = false
    @State private var showingUnblockDecision = false
    @StateObject private var notificationManager = NotificationManager.shared
    
    let appName: String
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text("We'll send you a notification")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Press the notification to decide if you really want to unblock \(appName)")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 12) {
                DSButton(
                    "Retry",
                    style: .primary,
                    size: .medium
                ) {
                    sendPushNotification()
                }
                
                DSButton(
                    "Didn't get push notification",
                    style: .secondary,
                    size: .medium
                ) {
                    showingNotificationSettings = true
                }
            }
        }
        .padding(.horizontal, 22)
        .onAppear {
            sendPushNotification()
        }
        .dsSheet(title: "Notification Settings", isPresented: $showingNotificationSettings) {
            NotificationSettingsView(isPresented: $showingNotificationSettings)
        }
        .dsSheet(title: "Unblock Decision", isPresented: $showingUnblockDecision) {
            UnblockDecisionView(isPresented: $showingUnblockDecision, appName: appName)
        }
    }
    
    private func sendPushNotification() {
        // Schedule push notification that will open the app
        let content = UNMutableNotificationContent()
        content.title = "App Access Request"
        content.body = "You requested access to \(appName). Tap to decide."
        content.sound = .default
        content.categoryIdentifier = "APP_ACCESS_REQUEST"
        content.userInfo = ["appName": appName, "action": "unblock_decision"]
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 3,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "app_access_request_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
        
        // For demo purposes, show the decision screen after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            showingUnblockDecision = true
        }
    }
}

struct NotificationSettingsView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "gear")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                
                Text("Enable Notifications")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("To receive blocking notifications, please enable notifications in Settings.")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Instructions
            VStack(alignment: .leading, spacing: 12) {
                Text("Steps:")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("1. Go to Settings")
                    Text("2. Find 'DoomScroll Blocker'")
                    Text("3. Enable 'Allow Notifications'")
                    Text("4. Return to this app")
                }
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            
            Spacer()
            
            DSButton(
                "Open Settings",
                style: .primary,
                size: .medium
            ) {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
        }
        .padding(.horizontal, 22)
    }
}

struct UnblockDecisionView: View {
    @Binding var isPresented: Bool
    @State private var showingRewardScreen = false
    @StateObject private var screenTimeManager = ScreenTimeManager()
    @StateObject private var levelManager = LevelManager.shared
    
    let appName: String
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
                
                Text("Final Decision")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Do you really want to unblock \(appName)?")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 12) {
                DSButton(
                    "Unblock",
                    style: .danger,
                    size: .medium
                ) {
                    // Unblock the app
                    levelManager.deductGems(20, reason: "Unblocked \(appName)")
                    screenTimeManager.activateEmergencyOverride()
                    isPresented = false
                }
                
                DSButton(
                    "Change My Mind",
                    style: .success,
                    size: .medium
                ) {
                    showingRewardScreen = true
                }
            }
        }
        .padding(.horizontal, 22)
        .dsSheet(title: "Great Choice!", isPresented: $showingRewardScreen) {
            RewardScreenView(isPresented: $showingRewardScreen, source: .pushNotificationScreen)
        }
    }
}

struct RewardScreenView: View {
    @Binding var isPresented: Bool
    @StateObject private var levelManager = LevelManager.shared
    @State private var rewardAmount = 0
    @State private var showingReward = false
    
    let source: RewardSource
    
    enum RewardSource {
        case blockingScreen
        case pushNotificationScreen
    }
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 16) {
                // Chest image (placeholder - you'll replace with actual gem image)
                Image(systemName: "gift.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                    .scaleEffect(showingReward ? 1.2 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showingReward)
                
                Text("Great Choice!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("We have a gift for you")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                
                if showingReward {
                    Text("+\(rewardAmount) Gems")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.yellow)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            Spacer()
            
            DSButton(
                "Continue",
                style: .success,
                size: .medium
            ) {
                isPresented = false
            }
            
            Spacer()
        }
        .padding(.horizontal, 22)
        .onAppear {
            calculateReward()
            showReward()
        }
    }
    
    private func calculateReward() {
        // Get daily change of mind count
        let dailyChanges = getDailyChangeMindCount()
        
        // Calculate reward based on frequency
        switch dailyChanges {
        case 0...2:
            rewardAmount = Int.random(in: 25...30)
        case 3...5:
            rewardAmount = Int.random(in: 20...25)
        case 6...8:
            rewardAmount = Int.random(in: 15...20)
        default:
            rewardAmount = Int.random(in: 10...15)
        }
    }
    
    private func showReward() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                showingReward = true
            }
            
            // Award the gems
            levelManager.addGems(rewardAmount, reason: "Changed mind about app access")
            
            // Increment daily change count
            incrementDailyChangeMindCount()
        }
    }
    
    private func getDailyChangeMindCount() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let key = "daily_change_mind_\(today.timeIntervalSince1970)"
        return UserDefaults.standard.integer(forKey: key)
    }
    
    private func incrementDailyChangeMindCount() {
        let today = Calendar.current.startOfDay(for: Date())
        let key = "daily_change_mind_\(today.timeIntervalSince1970)"
        let current = UserDefaults.standard.integer(forKey: key)
        UserDefaults.standard.set(current + 1, forKey: key)
    }
}

#Preview {
    CustomBlockingScreenView(appName: "Instagram")
} 
