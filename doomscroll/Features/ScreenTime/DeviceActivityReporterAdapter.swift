//
//  DeviceActivityReporterAdapter.swift
//  doomscroll
//
//  Created by Rabin on 7/22/25.
//

import SwiftUI
import DeviceActivity
import os.log

struct DeviceActivityReporterAdapter: View {
    private let logger = Logger(subsystem: "llc.doomscroll", category: "DeviceActivityReporterAdapter")
    @State private var isLoading = true
    @State private var loadingTimer: Timer? = nil
    @State private var elapsedTime = 0
    
    init() {
        logger.info("📊 DeviceActivityReporterAdapter initialized")
        let dateInterval = Calendar.current.dateInterval(of: .day, for: .now)!
        logger.info("📊 Date interval for filter: \(dateInterval.start) to \(dateInterval.end)")
    }
    
    // Use "Atividades" to match the repo's context name exactly
    @State private var context: DeviceActivityReport.Context = .init(rawValue: "Atividades")
    @State private var filter = DeviceActivityFilter(
        segment: .daily(
            during: Calendar.current.dateInterval(
                of: .day, for: .now
            )!
        ),
        users: .all,
        devices: .init([.iPhone])
    )
    
    var body: some View {
        // Log outside of the view hierarchy
        let _ = { logger.info("📊 DeviceActivityReporterAdapter body called with context: \(context.rawValue)") }()
        
        return ZStack {
            // Device Activity Report
            DeviceActivityReport(context, filter: filter)
                .opacity(isLoading ? 0 : 1) // Hide until data is loaded
                .onAppear {
                    logger.info("📊 DeviceActivityReport appeared in adapter")
                    
                    // Start a timer to check for data and update loading state
                    startLoadingTimer()
                    
                    // Check shared UserDefaults to see if data is available using multiple app group IDs
                    checkForData()
                }
            
            // Loading indicator
            if isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    
                    Text("Loading screen time data...")
                        .font(.headline)
                    
                    Text("This may take up to 30 seconds")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if elapsedTime >= 5 {
                        Text("\(elapsedTime) seconds elapsed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(radius: 5))
                .padding()
            }
        }
    }
    
    private func startLoadingTimer() {
        // Cancel any existing timer
        loadingTimer?.invalidate()
        
        // Create a new timer that fires every second
        loadingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime += 1
            
            // Check for data every 5 seconds
            if elapsedTime % 5 == 0 {
                checkForData()
            }
            
            // After 30 seconds, show the report anyway
            if elapsedTime >= 30 {
                withAnimation {
                    isLoading = false
                }
                loadingTimer?.invalidate()
                loadingTimer = nil
                logger.info("📊 Loading timeout reached, showing report")
            }
        }
    }
    
    private func checkForData() {
        let appGroupIds = ["group.llc.doomscroll.shared", "group.llc.doomscroll.shared"]
        var foundData = false
        
        for appGroupId in appGroupIds {
            if let sharedDefaults = UserDefaults(suiteName: appGroupId) {
                logger.info("📊 Checking shared UserDefaults with group ID: \(appGroupId)")
                
                // Check for timestamp first to verify extension is running
                if let timestamp = sharedDefaults.object(forKey: "dataUpdateTimestamp") as? TimeInterval {
                    let date = Date(timeIntervalSince1970: timestamp)
                    let formatter = DateFormatter()
                    formatter.dateStyle = .short
                    formatter.timeStyle = .medium
                    logger.info("📊 Found timestamp in shared UserDefaults: \(formatter.string(from: date))")
                    foundData = true
                }
                
                // Check for total screen time
                if let totalTime = sharedDefaults.object(forKey: "totalScreenTime") as? TimeInterval {
                    logger.info("📊 Found data in shared UserDefaults: totalScreenTime = \(totalTime)")
                    foundData = true
                }
                
                // Check for app count
                if let appCount = sharedDefaults.object(forKey: "totalAppCount") as? Int {
                    logger.info("📊 Found app count in shared UserDefaults: \(appCount) apps")
                }
                
                // Check for app reports data
                if let appReportsData = sharedDefaults.data(forKey: "appReportsData") {
                    logger.info("📊 Found appReportsData in shared UserDefaults, size: \(appReportsData.count) bytes")
                    foundData = true
                    
                    // Try to decode the data to verify it's valid
                    do {
                        let decoder = JSONDecoder()
                        let appReports = try decoder.decode([AppReport].self, from: appReportsData)
                        logger.info("📊 Successfully decoded \(appReports.count) app reports from shared UserDefaults")
                    } catch {
                        logger.error("❌ Failed to decode app reports from shared UserDefaults: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        // If data is found, stop loading
        if foundData {
            withAnimation {
                isLoading = false
            }
            loadingTimer?.invalidate()
            loadingTimer = nil
            logger.info("📊 Data found, showing report")
        } else {
            logger.error("❌ No data found in any shared UserDefaults group")
            
            // Write a test value to verify we can access shared UserDefaults
            for appGroupId in appGroupIds {
                if let sharedDefaults = UserDefaults(suiteName: appGroupId) {
                    sharedDefaults.set("Test from main app at \(Date())", forKey: "mainAppTest")
                    sharedDefaults.synchronize()
                    logger.info("📊 Wrote test value to shared UserDefaults with group ID: \(appGroupId)")
                }
            }
        }
    }
}


//struct DeviceActivityReporterAdapter: View {
//    
//    @State private var context: DeviceActivityReport.Context = .init(rawValue: "Atividades")
//    @State private var filter = DeviceActivityFilter(
//        segment: .daily(
//            during: Calendar.current.dateInterval(
//                of: .day, for: .now
//            )!
//        ),
//        users: .all,
//        devices: .init([.iPhone])
//    )
//    
//    var body: some View {
//        ZStack {
//            DeviceActivityReport(context, filter: filter)
//        }
//    }
//    
//}
