//
//  BlockingDetectionView.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import SwiftUI
import UserNotifications

struct BlockingDetectionView: View {
    @StateObject private var screenTimeManager = ScreenTimeManager()
    @State private var showingCustomBlockingScreen = false
    @State private var lastBlockedAppName = ""
    @State private var appReturnTime: Date?
    
    var body: some View {
        EmptyView()
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                handleAppReturnFromBackground()
            }
            .dsSheet(title: "App Blocked", isPresented: $showingCustomBlockingScreen) {
                CustomBlockingScreenView(appName: lastBlockedAppName)
            }
    }
    
    private func handleAppReturnFromBackground() {
        // Check if user just returned from a potentially blocked app
        guard screenTimeManager.isBlocking else { return }
        
        let now = Date()
        
        // If user returns quickly (within 5 seconds), they likely hit a blocked app
        if let lastReturn = appReturnTime,
           now.timeIntervalSince(lastReturn) < 5 {
            
            // Show custom blocking screen
            lastBlockedAppName = "Social Media App"
            showingCustomBlockingScreen = true
        }
        
        appReturnTime = now
    }
}

// MARK: - Enhanced CustomBlockingScreenView for this approach

struct EnhancedCustomBlockingScreenView: View {
    @State private var showingPushNotificationFlow = false
    @State private var showingRewardScreen = false
    @StateObject private var levelManager = LevelManager.shared
    @Environment(\.dismiss) private var dismiss
    
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
                    
                    Text("You tried to access a blocked app")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    Text("What would you like to do?")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    DSButton(
                        "Continue (Push Notification Flow)",
                        style: .warning,
                        size: .medium
                    ) {
                        showingPushNotificationFlow = true
                    }
                    
                    DSButton(
                        "Change My Mind (Get Gems)",
                        style: .success,
                        size: .medium
                    ) {
                        // Award gems immediately
                        let rewardAmount = Int.random(in: 15...25)
                        levelManager.addGems(rewardAmount, reason: "Changed mind about accessing blocked app")
                        showingRewardScreen = true
                    }
                    
                    DSButton(
                        "Close",
                        style: .secondary,
                        size: .medium
                    ) {
                        dismiss()
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .padding()
        }
        .dsSheet(title: "Push Notification Flow", isPresented: $showingPushNotificationFlow) {
            PushNotificationFlowView(isPresented: $showingPushNotificationFlow, appName: appName)
        }
        .dsSheet(title: "Great Choice!", isPresented: $showingRewardScreen) {
            RewardScreenView(isPresented: $showingRewardScreen, source: .blockingScreen)
        }
    }
} 
