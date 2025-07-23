//
//  TotalActivityView.swift
//  doomscrollReportExtension
//
//  Created by Rabin on 7/22/25.
//

import SwiftUI
import DeviceActivity
import os.log

struct TotalActivityView: View {
    private let logger = Logger(subsystem: "llc.doomscroll.doomscrollReportExtension", category: "TotalActivityView")
    var deviceActivity: DeviceActivity
    
    init(deviceActivity: DeviceActivity) {
        self.deviceActivity = deviceActivity
        logger.info("📊 TotalActivityView initialized with deviceActivity: \(deviceActivity.duration) seconds, \(deviceActivity.apps.count) apps")
    }
    
    var body: some View {
        logger.info("📊 TotalActivityView body called, rendering ActivitiesView")
        return ActivitiesView(activities: deviceActivity)
            .onAppear {
                logger.info("📊 TotalActivityView appeared")
                if deviceActivity.apps.isEmpty {
                    logger.warning("⚠️ TotalActivityView appeared with empty apps array")
                } else {
                    logger.info("📊 TotalActivityView showing \(deviceActivity.apps.count) apps")
                }
            }
    }
}

// MARK: - DeviceActivityReport Scene
// TotalActivityReport is now defined in TotalActivityReport.swift

// In order to support previews for your extension's custom views, make sure its source files are
// members of your app's Xcode target as well as members of your extension's target. You can use
// Xcode's File Inspector to modify a file's Target Membership.
#Preview {
    Text("Preview not available for DeviceActivityResults")
}
