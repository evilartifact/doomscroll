//
//  HiddenActivityCollector.swift
//  doomscroll
//
//  Created by Cascade on 7/19/25.
//

import SwiftUI
import DeviceActivity

struct HiddenActivityCollector: View {
    @EnvironmentObject private var screenTimeManager: ScreenTimeManager
    
    var body: some View {
        // This invisible view renders DeviceActivityReport to trigger data collection
        // The extension's .task will run when this view is rendered
        if let filter = screenTimeManager.createDeviceActivityFilter() {
            DeviceActivityReport(.totalActivity, filter: filter)
                .frame(width: 1, height: 1)  // Non-zero frame so extension runs
                .hidden()                    // Keeps it off-screen
                .allowsHitTesting(false)
        } else {
            EmptyView()
        }
    }
}

#Preview {
    HiddenActivityCollector()
}
