//
//  doomscrollReportExtension.swift
//  doomscrollReportExtension
//
//  Created by Rabin on 7/22/25.
//

import DeviceActivity
import SwiftUI
import os.log

@main
struct doomscrollReportExtension: DeviceActivityReportExtension {
    private static let logger = Logger(subsystem: "llc.doomscroll.doomscrollReportExtension", category: "doomscrollReportExtension")
    
    init() {
        // Log when extension is initialized
        Self.logger.info("📊 doomscrollReportExtension initialized")
        
        // Write a marker to shared UserDefaults to confirm extension is running
        // Try multiple app group identifiers to ensure compatibility
        let appGroupIds = ["group.llc.doomscroll.shared", "group.llc.doomscroll.shared"]
        var successfulWrite = false
        
        for appGroupId in appGroupIds {
            if let sharedDefaults = UserDefaults(suiteName: appGroupId) {
                // Write current date
                sharedDefaults.set(Date(), forKey: "extensionLastRun")
                
                // Write timestamp for easier comparison
                let timestamp = Date().timeIntervalSince1970
                sharedDefaults.set(timestamp, forKey: "extensionStartTimestamp")
                
                // Write a counter to track how many times the extension has been initialized
                let currentCount = sharedDefaults.integer(forKey: "extensionInitCount")
                sharedDefaults.set(currentCount + 1, forKey: "extensionInitCount")
                
                // Force synchronize to ensure data is written immediately
                sharedDefaults.synchronize()
                
                Self.logger.info("📊 Extension startup recorded in shared UserDefaults with group: \(appGroupId)")
                successfulWrite = true
            }
        }
        
        if !successfulWrite {
            Self.logger.error("❌ Failed to access any shared UserDefaults during extension initialization")
        }
    }
    
    var body: some DeviceActivityReportScene {
        // Log when body is called
        Self.logger.info("📊 doomscrollReportExtension body called")
        
        // Return the report
        return TotalActivityReport()
    }
}
