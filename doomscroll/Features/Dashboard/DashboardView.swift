//
//  DashboardView.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import SwiftUI
import FamilyControls

struct DashboardView: View {
    @StateObject private var levelManager = LevelManager.shared
    @StateObject private var habitManager = HabitManager.shared
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var screenTimeManager = ScreenTimeManager()
    @State private var showingEmergencyAccess = false
    @State private var showingMoodEntry = false
    @State private var showingStopBlockingSheet = false
    @State private var showingNewRule = false
    @State private var showingLevelCard = false
    @State private var showingAppPicker = false
    @State private var currentTime = Date()
    
    // State variables for draggable sheet
    @State private var offset: CGFloat = 0
    @State private var lastOffset: CGFloat = 0
    @State private var isSheetExpanded: Bool = false
    
    // Use a slower timer to reduce auto-scrolling
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                // Calculate the height needed for content above the sheet
                // Top padding (12) + statsRow (50) + spacing (12) + spacing (12)
                let contentAboveSheetHeight: CGFloat = 150
                
                // Available height excluding safe areas
                let usableHeight = geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
                
                // Position sheet just below the statsRow (measured from bottom)
                let sheetDefaultPosition = usableHeight - contentAboveSheetHeight
                
                // The highest position the sheet can go (near the top, leaving some space)
                let topPosition = -sheetDefaultPosition 
                
                ZStack(alignment: .bottom) {
                    // MARK: - Main Dashboard Content (Bottom Layer)
                    ZStack {
                        BackgroundView()
                        ScrollView{
                            LazyVStack(spacing: 12) {
                                // Stats Row
                                statsRow
                                
                                // Goblin Mood Display (replacing main level card)
                                goblinMoodCard
                                
                                // DeviceActivity Report Card - Shows real screen time data
                                deviceActivityReportCard
                                
                                
                                
                                Spacer(minLength: sheetDefaultPosition)
                                
                                
                            }
                        }
                            .padding(.top, 12)
                            .padding(.horizontal, 12)
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            HStack(spacing: 8) {
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.accentColor)
                                Text("This is fun")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            .padding(.vertical, 3)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showingLevelCard = true
                            }) {
                                Image(systemName: "rectangle.bottomhalf.filled")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    
                    // MARK: - Draggable BlockingView Sheet (Top Layer)
                    VStack(spacing: 0) {
                        // Drag Handle
                        Capsule()
                            .frame(width: 50, height: 6)
                            .foregroundColor(.white.opacity(0.2))
                            .padding(.top, 8)
                            .padding(.bottom, 8)
                        
                        // Sheet Content 
                        BlockingViewContent(isExpanded: isSheetExpanded)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(BackgroundView())
                    .ignoresSafeArea(edges: .bottom)
                    .offset(y: sheetDefaultPosition)
                    .offset(y: offset)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let newOffset = gesture.translation.height + self.lastOffset
                                // Clamp the offset between the top position and the minimum (0).
                                self.offset = max(topPosition, min(newOffset, 0))
                            }
                            .onEnded { gesture in
                                withAnimation(.easeOut(duration: 0.3)) {
                                    // Snap to top or default position based on drag distance
                                    if self.offset < -sheetDefaultPosition/2 {
                                        self.offset = topPosition
                                        self.isSheetExpanded = true
                                    } else {
                                        self.offset = 0
                                        self.isSheetExpanded = false
                                    }
                                }
                                self.lastOffset = self.offset
                            }
                    )
                }
            }
        }
        .onReceive(timer) { _ in
            // Only update if needed to prevent constant refreshes
            if abs(currentTime.timeIntervalSince(Date())) > 60 {
                currentTime = Date()
            }
        }
        .dsSheet(title: "Emergency Access", isPresented: $showingEmergencyAccess) {
            EmergencyAccessView(isPresented: $showingEmergencyAccess)
        }
        .dsSheet(title: "Quick Mood Check", isPresented: $showingMoodEntry) {
            QuickMoodEntryView(isPresented: $showingMoodEntry)
        }
        .dsSheet(title: "Stop Blocking?", isPresented: $showingStopBlockingSheet) {
            StopBlockingReasonSheet(isPresented: $showingStopBlockingSheet)
        }
        .dsSheet(title: "New Blocking Rule", isPresented: $showingNewRule) {
            NewBlockingRuleView(isPresented: $showingNewRule)
        }
        .sheet(isPresented: $showingLevelCard) {
            LevelCardView(isPresented: $showingLevelCard)
                .presentationDetents([.height(400)])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(0)
        }
        .onAppear {
            // Request Screen Time authorization when the dashboard loads
            Task {
                await screenTimeManager.requestScreenTimePermission()
            }
        }
    }

    
    private var statsRow: some View {
        HStack(spacing: 12) {
            // Time Clean (since last social media use)
            DSCard {
                VStack(spacing: 8) {
                    Text(timeCleanDisplay)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Time Clean")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
            }
            
            // Apps Blocked - only show count when actually blocking
            DSCard {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "shield.fill")
                            .foregroundColor(screenTimeManager.isBlocking ? .red : .gray)
                        Text(screenTimeManager.isBlocking ? "\(screenTimeManager.blockedApps.count)" : "0")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text("Apps Blocked")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
            }
        }
    }
    
    

    
    private var timeCleanDisplay: String {
        let timeSinceLastUse = levelManager.timeSinceLastSocialMedia
        let hours = timeSinceLastUse / 3600
        let minutes = (timeSinceLastUse.truncatingRemainder(dividingBy: 3600)) / 60
        let days = timeSinceLastUse / 86400
        
        if days >= 1 {
            return "\(Int(days))d \(Int(hours.truncatingRemainder(dividingBy: 24)))h"
        } else if hours >= 1 {
            return "\(Int(hours))h \(Int(minutes))m"
        } else {
            return "\(Int(minutes))m"
        }
    }
    
    
    // MARK: - Screen Time Activity View (UI Only)
    private var deviceActivityReportCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Real Screen Time Data")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Refresh") {
                    screenTimeManager.refreshData()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            // UI-Only ActivityView - reads data from MonitorExtension
            if screenTimeManager.authorizationStatus == .approved {
                ActivityView()
                    .frame(height: 200)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("Screen Time Authorization Required")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Grant access in BlockingView to see your real screen time data")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                    
                    Button("Grant Access") {
                        Task {
                            await screenTimeManager.requestScreenTimePermission()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.caption)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.3))
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.black.opacity(0.2))
        .cornerRadius(12)
        .padding(.horizontal, 12)
    }
}




extension DashboardView {
    // MARK: - Goblin Mood Card
    private var goblinMoodCard: some View {
        goblinMoodCardContent
    }
    
    @ViewBuilder
    private var goblinMoodCardContent: some View {
        VStack(spacing: 0) {
            goblinCardHeader
            goblinCardBody
        }
        .background(goblinCardBackground)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .familyActivityPicker(isPresented: $showingAppPicker, selection: $screenTimeManager.screenTimeSelection)
        .onChange(of: screenTimeManager.screenTimeSelection) { newSelection in
            Task {
                await screenTimeManager.updateScreenTimeSelection(newSelection)
            }
        }
    }
    
    private var goblinCardHeader: some View {
        HStack {
            Text("Today's Screen Time")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            Spacer()
            if screenTimeManager.isCollectingData {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(.white)
            } else {
                Text("\(screenTimeManager.getTodayScore())")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var goblinCardBody: some View {
        if screenTimeManager.authorizationStatus != .approved {
            permissionRequestView
        } else if screenTimeManager.needsAppSelection || screenTimeManager.screenTimeSelection.applicationTokens.isEmpty {
            appSelectionView
        } else {
            screenTimeDataView
        }
    }
    
    private var permissionRequestView: some View {
        VStack(spacing: 16) {
            Image("excited")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .padding(.vertical, 16)
            
            VStack(spacing: 8) {
                Text("Screen Time Permission Needed")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Grant permission to track your screen time and get personalized scores")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    Task {
                        await screenTimeManager.requestScreenTimePermission()
                    }
                }) {
                    Text("Grant Permission")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
                .padding(.top, 8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private var appSelectionView: some View {
        VStack(spacing: 16) {
            Image("excited")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .padding(.vertical, 16)
            
            VStack(spacing: 8) {
                Text("Select Apps to Monitor")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Choose which apps you want to track for your daily screen time report")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    showingAppPicker = true
                }) {
                    HStack {
                        Image(systemName: "app.fill")
                        Text("Select Apps")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .cornerRadius(20)
                }
                .padding(.top, 8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private var screenTimeDataView: some View {
        VStack(spacing: 16) {
            Image("\(screenTimeManager.getCurrentGoblinMood().rawValue)")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .padding(.vertical, 16)
            
            VStack(spacing: 8) {
                Text(screenTimeManager.getFormattedScreenTime())
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Text("Monitoring \(screenTimeManager.screenTimeSelection.applicationTokens.count) apps")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                
                Button(action: {
                    showingAppPicker = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.system(size: 12))
                        Text("Change Apps")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    private var goblinCardBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }

    
    private func formatAppUsageTime(_ timeInterval: TimeInterval) -> String {
        let totalMinutes = Int(timeInterval) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}


#Preview {
    DashboardView()
} 
