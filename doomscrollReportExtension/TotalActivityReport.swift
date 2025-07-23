//
//  TotalActivityReport.swift
//  doomscrollReportExtension
//
//  Created by Rabin on 7/22/25.
//

import DeviceActivity
import SwiftUI
import os.log

extension DeviceActivityReport.Context {
    // If your app initializes a DeviceActivityReport with this context, then the system will use
    // your extension's corresponding DeviceActivityReportScene to render the contents of the
    // report.
    static let totalActivity = Self("Atividades")
}

struct TotalActivityReport: DeviceActivityReportScene {
    // Define which context your scene will represent.
    let context: DeviceActivityReport.Context = .totalActivity
    
    // Logger for debugging - static to avoid capture issues
    private static let debugLogger = Logger(subsystem: "llc.doomscroll.doomscrollReportExtension", category: "TotalActivityReport")
    
    // Define the custom configuration and the resulting view for this report.
    var content: (DeviceActivity) -> TotalActivityView {
        return { deviceActivity in
            TotalActivityReport.debugLogger.info("📊 Rendering TotalActivityView with deviceActivity: \(deviceActivity.duration) seconds, \(deviceActivity.apps.count) apps")
            return TotalActivityView(deviceActivity: deviceActivity)
        }
    }
    
    // Helper function to write debug markers to UserDefaults
    private func writeDebugMarker() {
        let appGroupIds = ["group.llc.doomscroll.shared", "group.llc.doomscroll.shared", "group.llc.doomscroll"]
        var successfulWrite = false
        
        for appGroupId in appGroupIds {
            if let sharedDefaults = UserDefaults(suiteName: appGroupId) {
                // Write a simple marker with timestamp
                let timestamp = Date().timeIntervalSince1970
                let marker = "TotalActivityReport.makeConfiguration called at \(Date())"
                
                sharedDefaults.set(marker, forKey: "extensionDebugMarker")
                sharedDefaults.set(timestamp, forKey: "extensionDebugTimestamp")
                
                // Force synchronize
                sharedDefaults.synchronize()
                
                TotalActivityReport.debugLogger.info("📊 Debug marker written to UserDefaults with group: \(appGroupId)")
                successfulWrite = true
            }
        }
        
        if !successfulWrite {
            TotalActivityReport.debugLogger.error("❌ Failed to write debug marker to any UserDefaults")
        }
    }
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> DeviceActivity {
        TotalActivityReport.debugLogger.info("📊 makeConfiguration called with data")
        
        // Write a marker immediately to confirm this method is called
        writeDebugMarker()
        
        var list: [AppReport] = []
        let totalActivityDuration = await data.flatMap { $0.activitySegments }.reduce(0, {
            $0 + $1.totalActivityDuration
        })
        
        TotalActivityReport.debugLogger.info("📊 Processing activity segments")
        
        for await _data in data {
            for await activity in _data.activitySegments {
                TotalActivityReport.debugLogger.info("📊 Processing segment")
                
                for await category in activity.categories {
                    TotalActivityReport.debugLogger.info("📊 Processing category")
                    
                    for await app in category.applications {
                        let appName = (app.application.localizedDisplayName ?? "nil")
                        TotalActivityReport.debugLogger.info("📊 Found activity: \(appName), duration: \(app.totalActivityDuration) seconds")
                        
                        let bundle = (app.application.bundleIdentifier ?? "nil")
                        let duration = app.totalActivityDuration
                        let app = AppReport(id: bundle, name: appName, duration: duration)
                        list.append(app)
                    }
                }
            }
        }
        
        // Save data to shared UserDefaults for debugging
        // Try multiple app group identifiers to ensure compatibility
        let appGroupIds = ["group.llc.doomscroll.shared", "group.llc.doomscroll.shared", "group.llc.doomscroll"]
        var savedSuccessfully = false
        
        // Log the data we're about to save
        TotalActivityReport.debugLogger.info("📊 Attempting to save data to shared UserDefaults: \(totalActivityDuration) seconds, \(list.count) apps")
        if list.isEmpty {
            TotalActivityReport.debugLogger.warning("⚠️ No app data found to save")
        }
        
        for appGroupId in appGroupIds {
            if let sharedDefaults = UserDefaults(suiteName: appGroupId) {
                // Save total duration
                sharedDefaults.set(totalActivityDuration, forKey: "totalScreenTime")
                
                // Save app count
                sharedDefaults.set(list.count, forKey: "totalAppCount")
                
                // Save timestamp for data freshness checking
                sharedDefaults.set(Date(), forKey: "lastScreenTimeUpdate")
                sharedDefaults.set(Date().timeIntervalSince1970, forKey: "dataUpdateTimestamp")
                
                // Save app reports data
                if let encodedData = try? JSONEncoder().encode(list) {
                    sharedDefaults.set(encodedData, forKey: "appReportsData")
                    TotalActivityReport.debugLogger.info("📊 Saved \(list.count) app reports to shared UserDefaults with group: \(appGroupId)")
                    savedSuccessfully = true
                } else {
                    TotalActivityReport.debugLogger.error("❌ Failed to encode app reports for shared UserDefaults")
                }
                
                // Force synchronize to ensure data is written immediately
                sharedDefaults.synchronize()
            }
        }
        
        if savedSuccessfully {
            TotalActivityReport.debugLogger.info("📊 Successfully saved data to shared UserDefaults")
        } else {
            TotalActivityReport.debugLogger.error("❌ Failed to access any shared UserDefaults")
        }
        
        TotalActivityReport.debugLogger.info("📊 Total processed: \(totalActivityDuration) seconds across \(list.count) apps")
        
        let result = DeviceActivity(duration: totalActivityDuration, apps: list)
        TotalActivityReport.debugLogger.info("📊 Returning DeviceActivity with duration: \(result.duration), apps: \(result.apps.count)")
        return result
    }
}
