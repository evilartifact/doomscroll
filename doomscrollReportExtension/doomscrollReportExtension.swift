import DeviceActivity
import SwiftUI
import Foundation

@main
struct doomscrollReportExtension: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        TotalActivityReport()
    }
}

extension DeviceActivityReport.Context {
    static let totalActivity = Self("totalActivity")
}

// Import the shared DeviceActivityName extension
extension DeviceActivityName {
    static let totalActivity = Self("totalActivity")
} 