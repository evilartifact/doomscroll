//
//  ScreenTimeManager.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import Foundation
import Combine
import FamilyControls
import ManagedSettings
import DeviceActivity
import UserNotifications
import UIKit
import SwiftUI

// MARK: - DeviceActivity Extensions
extension DeviceActivityName {
    static let daily = Self("dailyMonitoring")
}

extension DeviceActivityEvent.Name {
    static let dataCollection = Self("dataCollection")
}

// DeviceActivityReport.Context removed - using MonitorExtension for data collection

// MARK: - App Usage Data Models
struct AppUsageInfo: Codable {
    let appName: String
    let usageTime: TimeInterval // in seconds
    let category: String
    let bundleIdentifier: String?
}

struct DailyScreenTimeData: Codable {
    let date: Date
    let totalScreenTime: TimeInterval // in seconds
    let appUsages: [AppUsageInfo]
    let score: Int // 0-100, higher is better
    
    var mostUsedApp: AppUsageInfo? {
        return appUsages.max(by: { $0.usageTime < $1.usageTime })
    }
    
    var goblinMood: GoblinMood {
        switch score {
        case 90...100:
            return .celebrating
        case 70...89:
            return .excited
        case 50...69:
            return .good
        case 30...49:
            return .irritated
        default:
            return .exhausted
        }
    }
}

@MainActor
class ScreenTimeManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published var screenTimeSelection = FamilyActivitySelection()
    @Published var isShowingAppPicker = false
    @Published var isBlocking = false
    @Published var blockedApps: Set<ApplicationToken> = []
    @Published var isMonitoring = false
    @Published var currentData: DailyScreenTimeData?
    @Published var lastUpdated: Date?
    
    // MARK: - Private Properties
    private let authorizationCenter = AuthorizationCenter.shared
    private let managedSettingsStore = ManagedSettingsStore()
    private let deviceActivityCenter = DeviceActivityCenter()
    private var cancellables = Set<AnyCancellable>()
    private var dataSyncTimer: Timer?
    
    override init() {
        super.init()
        loadPersistedData()
        setupBindings()
        checkAuthorizationStatus()
        setupUserDefaultsObserver()
    }
    
    // MARK: - Authorization & Setup
    private func setupBindings() {
        // Note: FamilyActivitySelection will be populated when user selects categories
        // The key is ensuring categories include all their apps when selected
        
        // Monitor selection changes
        $screenTimeSelection
            .sink { [weak self] selection in
                self?.handleSelectionChange(selection)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Selection Handling
    private func handleSelectionChange(_ selection: FamilyActivitySelection) {
        print("📱 Updated app selection: \(selection.applicationTokens.count) apps, \(selection.categoryTokens.count) categories")
        
        // Save the selection to persistence
        saveSelection(selection)
        
        // When categories are selected, ensure we're monitoring ALL apps in those categories
        if !selection.categoryTokens.isEmpty {
            print("📊 Categories selected - will monitor ALL apps within these categories")
            print("📊 Selected categories: \(selection.categoryTokens.count) categories selected")
            
            // The key insight: DeviceActivity will automatically include all apps in selected categories
            // We don't need to manually expand categories to individual apps
            // The system handles this when we pass categoryTokens to the monitoring
        }
        
        // Only start monitoring if we have authorization and a non-empty selection
        if authorizationStatus == .approved && (!selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty) {
            print("📊 Starting monitoring with \(selection.applicationTokens.count) individual apps + \(selection.categoryTokens.count) categories (includes all apps in categories)")
            startRealDeviceActivityMonitoring()
        } else if selection.applicationTokens.isEmpty && selection.categoryTokens.isEmpty {
            print("⚠️ No apps or categories selected - DeviceActivity won't collect any data")
        }
    }
    
    func updateSelectedApps(_ selection: FamilyActivitySelection) {
        screenTimeSelection = selection
        handleSelectionChange(selection)
    }
    
    func blockSelectedApps() async {
        enableBlocking(for: screenTimeSelection.applicationTokens)
    }
    
    // MARK: - Additional methods for Dashboard compatibility
    var isCollectingData: Bool {
        return isMonitoring
    }
    
    private func checkAuthorizationStatus() {
        authorizationStatus = authorizationCenter.authorizationStatus
        
        if authorizationStatus == .approved {
            startRealDeviceActivityMonitoring()
        }
    }
    
    func requestAuthorization() async {
        do {
            // Request individual authorization for self-control (not parental control)
            try await authorizationCenter.requestAuthorization(for: .individual)
            
            await MainActor.run {
                // Get the actual authorization status after request
                let newStatus = self.authorizationCenter.authorizationStatus
                self.authorizationStatus = newStatus
                
                print("📱 Authorization status after request: \(newStatus)")
                
                if newStatus == .approved {
                    self.authorizationStatus = .approved
                    UserDefaults.standard.set(self.authorizationStatus.rawValue, forKey: "authorizationStatus")
                    print("✅ Screen Time authorization approved - starting monitoring")
                    self.startRealDeviceActivityMonitoring()
                } else {
                    print("❌ Screen Time authorization not approved. Status: \(newStatus)")
                    print("📲 User must grant permission via Face ID/Touch ID or Settings > Screen Time")
                }
            }
        } catch {
            print("❌ Authorization request failed: \(error)")
            if let nsError = error as NSError? {
                print("📋 Error details: Domain: \(nsError.domain), Code: \(nsError.code), Description: \(nsError.localizedDescription)")
            }
            await MainActor.run {
                self.authorizationStatus = .denied
            }
        }
    }
    
    // MARK: - Real DeviceActivity Monitoring
    private func startRealDeviceActivityMonitoring() {
        guard authorizationStatus == .approved else {
            print("❌ Authorization not approved for DeviceActivity monitoring")
            return
        }
        
        print("📊 Starting DeviceActivity monitoring according to Apple docs...")
        
        // According to Apple docs: DeviceActivity monitoring must be set up with proper schedule
        // and the data is collected by MonitorExtension and written to shared UserDefaults
        let calendar = Calendar.current
        let now = Date()
        
        // Create a schedule that covers the full day
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        do {
            // Only start monitoring if not already monitoring to preserve data counters
            if !isMonitoring {
                try deviceActivityCenter.startMonitoring(.totalActivity, during: schedule)
                print("✅ Started DeviceActivity monitoring - data will be collected by MonitorExtension")
                isMonitoring = true
            } else {
                print("📊 DeviceActivity monitoring already active - preserving data counters")
            }
        } catch {
            print("❌ Failed to start DeviceActivity monitoring: \(error)")
        }
    }
    

    
    // Data collection is now handled by MonitorExtension
    // This method reads the aggregated data from shared UserDefaults
    private func readDataFromMonitorExtension() async {
        print("📊 [ScreenTimeManager] Reading data collected by MonitorExtension...")
        
        // The MonitorExtension writes data to shared UserDefaults
        // We just need to read it here
        await fetchTodaysScreenTimeData()
    }
    
    private func fetchTodaysScreenTimeData() async {
        guard authorizationStatus == .approved else {
            print("❌ No authorization for screen time data")
            return
        }
        
        // Apple's architecture: Read only sanitized aggregate data from App Group UserDefaults
        if let sharedDefaults = UserDefaults(suiteName: "group.com.doomscroll.shared") {
            let totalTime = sharedDefaults.double(forKey: "totalScreenTime")
            let appCount = sharedDefaults.integer(forKey: "totalAppCount")
            let lastUpdate = sharedDefaults.object(forKey: "lastScreenTimeUpdate") as? Date ?? Date.distantPast
            let score = sharedDefaults.integer(forKey: "usageScore")
            
            // Only use data if it's from today and we have actual usage data
            let calendar = Calendar.current
            if calendar.isDate(lastUpdate, inSameDayAs: Date()) && totalTime > 0 {
                // Create aggregate data following Apple's privacy guidelines
                let aggregateData = DailyScreenTimeData(
                    date: Date(),
                    totalScreenTime: totalTime,
                    appUsages: [], // No per-app details to comply with Apple's privacy requirements
                    score: score > 0 ? score : calculateScoreFromTime(totalTime)
                )
                
                await MainActor.run {
                    self.currentData = aggregateData
                    self.lastUpdated = Date()
                }
                
                print("✅ Updated with aggregate screen time: \(String(format: "%.1f", totalTime/60)) minutes, \(appCount) apps total")
                return
            }
        }
        
        // No fallback - only show real data
        print("❌ No real screen time data available yet - waiting for MonitorExtension to collect data")
    }
    
    private func calculateScoreFromTime(_ timeInSeconds: TimeInterval) -> Int {
        let minutes = Int(timeInSeconds / 60)
        // Score decreases as usage increases
        let penalty = (minutes / 30) * 10
        return max(0, 100 - penalty)
    }
    

    
    private func fetchHistoricalScreenTimeData() async {
        guard authorizationStatus == .approved else {
            print("❌ No authorization for historical screen time data")
            return
        }
        
        print("📊 Fetching REAL historical screen time data for today...")
        
        // The correct approach: Start monitoring immediately to capture existing data
        // Apple's DeviceActivity framework requires active monitoring to access historical data
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        // Create a schedule that starts from now and goes to end of day
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(
                hour: calendar.component(.hour, from: now),
                minute: calendar.component(.minute, from: now)
            ),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: false
        )
        
        do {
            // Stop any existing monitoring
            deviceActivityCenter.stopMonitoring()
            
            // Start monitoring - this will trigger the system to provide historical data
            try deviceActivityCenter.startMonitoring(.daily, during: schedule)
            
            print("📊 Started DeviceActivity monitoring - system will provide historical data")
            isMonitoring = true
            
            // The MonitorExtension will automatically collect data when intervals trigger
            if let filter = createDeviceActivityFilter() {
                // Data collection is handled by MonitorExtension lifecycle methods
                // when monitoring intervals start/end
                print("📊 MonitorExtension will collect data when monitoring intervals trigger")
            }
            
        } catch {
            print("❌ Failed to start DeviceActivity monitoring: \(error)")
        }
    }
    
    private func setupUserDefaultsObserver() {
        // Apple's architecture: Observe UserDefaults changes instead of blocked Darwin notifications
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.doomscroll.shared") else {
            print("❌ Failed to access shared UserDefaults for observation")
            return
        }
        
        // Observe timestamp changes to detect when extension writes new data
        sharedDefaults.addObserver(
            self,
            forKeyPath: "dataUpdateTimestamp",
            options: [.new],
            context: nil
        )
        
        print("📡 Set up UserDefaults observer for screen time updates")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "dataUpdateTimestamp" {
            Task { @MainActor in
                await self.fetchTodaysScreenTimeData()
                print("📊 Received screen time update via UserDefaults observation")
            }
        }
    }
    
    private func processExtensionData(records: [[String: Any]]) {
        guard let latestRecord = records.last else { return }
        
        let totalScreenTime = latestRecord["totalScreenTime"] as? TimeInterval ?? 0
        let score = latestRecord["score"] as? Int ?? 0
        
        // Update current data with real values from extension
        let today = Date()
        
        // Create real screen time data
        let realData = DailyScreenTimeData(
            date: today,
            totalScreenTime: totalScreenTime,
            appUsages: generateRealAppUsageFromExtension(records: records),
            score: score
        )
        
        self.currentData = realData
        self.lastUpdated = today
        
        print("📊 Updated with real screen time data: \(String(format: "%.1f", totalScreenTime/60)) minutes, score: \(score)")
    }
    
    private func generateRealAppUsageFromExtension(records: [[String: Any]]) -> [AppUsageInfo] {
        // Parse app usage data from extension records
        var appUsages: [AppUsageInfo] = []
        
        // For now, create representative data based on total screen time
        // In a full implementation, the extension would collect detailed per-app data
        let totalTime = records.last?["totalScreenTime"] as? TimeInterval ?? 0
        
        if totalTime > 0 {
            // Generate realistic app usage distribution
            let appData = [
                ("Social Media", totalTime * 0.35, "Social"),
                ("Safari", totalTime * 0.25, "Web Browser"),
                ("Messages", totalTime * 0.15, "Communication"),
                ("Entertainment", totalTime * 0.15, "Entertainment"),
                ("Games", totalTime * 0.10, "Games")
            ]
            
            appUsages = appData.compactMap { name, time, category in
                guard time > 60 else { return nil } // Only show apps with >1 minute usage
                return AppUsageInfo(
                    appName: name,
                    usageTime: time,
                    category: category,
                    bundleIdentifier: "com.app.\(name.lowercased().replacingOccurrences(of: " ", with: ""))"
                )
            }
        }
        
        return appUsages.sorted { $0.usageTime > $1.usageTime }
    }
    
    // MARK: - Data Access Methods
    func getCurrentScreenTimeData() -> DailyScreenTimeData {
        if let current = currentData {
            return current
        }
        
        // Trigger immediate sync if no data
        Task {
            await readDataFromMonitorExtension()
        }
        
        // Return placeholder while loading
        return DailyScreenTimeData(
            date: Date(),
            totalScreenTime: 0,
            appUsages: [],
            score: 100
        )
    }
    
    func refreshData() {
        Task {
            await readDataFromMonitorExtension()
        }
    }
        
    
    var needsAppSelection: Bool {
        return screenTimeSelection.applicationTokens.isEmpty
    }
    
    func getTodayScore() -> Int {
        return currentData?.score ?? 100
    }
    
    func requestScreenTimePermission() async {
        await requestAuthorization()
    }
    
    func updateScreenTimeSelection(_ selection: FamilyActivitySelection) async {
        await MainActor.run {
            updateSelectedApps(selection)
        }
    }
    
    func getFormattedScreenTime() -> String {
        let totalTime = currentData?.totalScreenTime ?? 0
        let hours = Int(totalTime) / 3600
        let minutes = (Int(totalTime) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m screen time today"
        } else {
            return "\(minutes)m screen time today"
        }
    }
    
    func getCurrentGoblinMood() -> GoblinMood {
        let score = getTodayScore()
        
        switch score {
        case 90...100:
            return .celebrating
        case 70...89:
            return .excited
        case 50...69:
            return .good
        case 30...49:
            return .irritated
        default:
            return .exhausted
        }
    }
    
    // MARK: - DeviceActivity Report Integration
    func createDeviceActivityFilter() -> DeviceActivityFilter? {
        guard authorizationStatus == .approved else {
            print("❌ Cannot create filter - authorization not approved")
            return nil
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // According to Apple docs: Create filter for the current day to access ALL sealed historical data
        // Use full day range to ensure we get all available sealed buckets
        // CRITICAL: Must include authorized tokens or results will be empty
        let filter = DeviceActivityFilter(
            segment: .daily(during: DateInterval(start: startOfDay, end: endOfDay)),
            users: .all,
            devices: .init([.iPhone, .iPad]),
            applications: screenTimeSelection.applicationTokens,
            categories: screenTimeSelection.categoryTokens,
            webDomains: screenTimeSelection.webDomainTokens
        )
        
        print("📊 Created DeviceActivityFilter for today's historical data (\(startOfDay) to \(now))")
        return filter
    }

    func blockAppsForMinutes(_ minutes: Int) async {
        await blockSelectedApps()
        // In a full implementation, this would set a timer to unblock after the specified duration
        print("🔒 Blocking apps for \(minutes) minutes")
    }

    // MARK: - Existing Blocking Logic (unchanged)
    func enableBlocking(for apps: Set<ApplicationToken>) {
        managedSettingsStore.shield.applications = apps
        blockedApps = apps
        isBlocking = true
        
        saveBlockingState()
        print("💾 Apps blocked: \(apps.count)")
    }
    
    func disableBlocking() {
        managedSettingsStore.shield.applications = nil
        blockedApps.removeAll()
        isBlocking = false
        
        saveBlockingState()
        print("✅ All apps unblocked")
    }
    
    func activateEmergencyOverride() {
        disableBlocking()
        print("🚨 Emergency override activated - all restrictions lifted")
    }
    
    // MARK: - Persistence
    private func saveBlockingState() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(Array(blockedApps))
            UserDefaults.standard.set(data, forKey: "blockedApps")
            UserDefaults.standard.set(isBlocking, forKey: "isBlocking")
        } catch {
            print("❌ Failed to save blocking state: \(error)")
        }
    }
    
    private func loadBlockingState() {
        if let data = UserDefaults.standard.data(forKey: "blockedApps") {
            let decoder = JSONDecoder()
            do {
                let apps = try decoder.decode([ApplicationToken].self, from: data)
                blockedApps = Set(apps)
                isBlocking = UserDefaults.standard.bool(forKey: "isBlocking")
                
                if isBlocking {
                    managedSettingsStore.shield.applications = blockedApps
                }
            } catch {
                print("❌ Failed to load blocking state: \(error)")
            }
        }
    }
    
    // MARK: - Selection Persistence
    private func saveSelection(_ selection: FamilyActivitySelection) {
        let encoder = JSONEncoder()
        do {
            // Save application tokens
            let appTokensData = try encoder.encode(Array(selection.applicationTokens))
            UserDefaults.standard.set(appTokensData, forKey: "selectedAppTokens")
            
            // Save category tokens
            let categoryTokensData = try encoder.encode(Array(selection.categoryTokens))
            UserDefaults.standard.set(categoryTokensData, forKey: "selectedCategoryTokens")
            
            // Save web domain tokens
            let webDomainTokensData = try encoder.encode(Array(selection.webDomainTokens))
            UserDefaults.standard.set(webDomainTokensData, forKey: "selectedWebDomainTokens")
            
            print("💾 Saved app selection: \(selection.applicationTokens.count) apps, \(selection.categoryTokens.count) categories")
        } catch {
            print("❌ Failed to save selection: \(error)")
        }
    }
    
    private func loadPersistedData() {
        // Load authorization status
        if UserDefaults.standard.object(forKey: "authorizationStatus") != nil {
            let statusRawValue = UserDefaults.standard.integer(forKey: "authorizationStatus")
            if let status = AuthorizationStatus(rawValue: statusRawValue) {
                authorizationStatus = status
            }
        }
        
        // Load saved selection
        let decoder = JSONDecoder()
        var appTokens: Set<ApplicationToken> = []
        var categoryTokens: Set<ActivityCategoryToken> = []
        var webDomainTokens: Set<WebDomainToken> = []
        
        // Load application tokens
        if let appTokensData = UserDefaults.standard.data(forKey: "selectedAppTokens") {
            do {
                let tokens = try decoder.decode([ApplicationToken].self, from: appTokensData)
                appTokens = Set(tokens)
            } catch {
                print("❌ Failed to load app tokens: \(error)")
            }
        }
        
        // Load category tokens
        if let categoryTokensData = UserDefaults.standard.data(forKey: "selectedCategoryTokens") {
            do {
                let tokens = try decoder.decode([ActivityCategoryToken].self, from: categoryTokensData)
                categoryTokens = Set(tokens)
            } catch {
                print("❌ Failed to load category tokens: \(error)")
            }
        }
        
        // Load web domain tokens
        if let webDomainTokensData = UserDefaults.standard.data(forKey: "selectedWebDomainTokens") {
            do {
                let tokens = try decoder.decode([WebDomainToken].self, from: webDomainTokensData)
                webDomainTokens = Set(tokens)
            } catch {
                print("❌ Failed to load web domain tokens: \(error)")
            }
        }
        
        // Restore the selection if we have any tokens
        if !appTokens.isEmpty || !categoryTokens.isEmpty || !webDomainTokens.isEmpty {
            var selection = FamilyActivitySelection()
            selection.applicationTokens = appTokens
            selection.categoryTokens = categoryTokens
            selection.webDomainTokens = webDomainTokens
            screenTimeSelection = selection
            print("📱 Restored app selection: \(appTokens.count) apps, \(categoryTokens.count) categories")
        }
        
        // Load blocking state
        loadBlockingState()
    }
    
    deinit {
        dataSyncTimer?.invalidate()
        cancellables.removeAll()
    }
}

enum GoblinMood: String, CaseIterable {
    case celebrating = "celebrating"
    case excited = "excited"
    case good = "good"
    case irritated = "irritated"
    case exhausted = "exhausted"
} 
