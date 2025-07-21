import SwiftUI
import DeviceActivity
import ManagedSettings
import FamilyControls

struct TotalActivityView: View {
    let totalActivity: DeviceActivityResults<DeviceActivityData>
    
    // State variables to store real aggregated data
    @State private var totalScreenTime: TimeInterval = 0
    @State private var monitoredAppsCount: Int = 0
    @State private var activityScore: Int = 50
    @State private var isProcessing: Bool = true
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Real Screen Time Data")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top)
            
            // Display the actual screen time data
            VStack(alignment: .leading, spacing: 12) {
                // Total screen time for the day
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.blue)
                    Text("Total Screen Time")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Spacer()
                    Text(formatTotalTime())
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                // App usage summary
                HStack {
                    Image(systemName: "apps.iphone")
                        .foregroundColor(.green)
                    Text("Apps Monitored")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(getAppsCount())")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                // Activity score
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.orange)
                    Text("Activity Score")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(calculateUsageScore())/100")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Status indicator
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Collecting real device data")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                }
            }
            .padding()
            .background(Color.black.opacity(0.1))
            .cornerRadius(12)
            .task {
                // Apple's architecture: Write sanitized aggregate data from within the extension view
                await processAndWriteAggregateData()
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private func formatTotalTime() -> String {
        if isProcessing {
            return "Loading..."
        }
        
        let hours = Int(totalScreenTime) / 3600
        let minutes = (Int(totalScreenTime) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func getAppsCount() -> Int {
        return monitoredAppsCount
    }
    
    private func calculateUsageScore() -> Int {
        return activityScore
    }
    
    private func processAndWriteAggregateData() async {
        print("📊 [ReportExtension] Processing real DeviceActivityResults data…")
        
        // Variables to track real usage data
        var totalDuration: TimeInterval = 0
        var appCount = 0
        var hasData = false
        
        // Process DeviceActivityResults to extract real usage data
        do {
            for try await segment in totalActivity {
                hasData = true
                print("📊 [ReportExtension] Processing activity data segment")
                
                // Use reflection to safely extract data from DeviceActivityData
                let mirror = Mirror(reflecting: segment)
                var segmentDuration: TimeInterval = 0
                var segmentAppCount = 0
                
                for child in mirror.children {
                    if let label = child.label {
                        print("🔍 [ReportExtension] Found property: \(label) of type \(type(of: child.value))")
                        
                        // Look for duration-related properties
                        if label.lowercased().contains("duration") {
                            if let duration = child.value as? TimeInterval {
                                segmentDuration += duration
                                print("⏱️ [ReportExtension] Found duration: \(duration) seconds")
                            }
                        }
                        
                        // Look for app-related collections
                        if label.lowercased().contains("app") || label.lowercased().contains("token") {
                            // Try to extract count from collections
                            if let collection = child.value as? any Collection {
                                let count = collection.count
                                segmentAppCount = max(segmentAppCount, count)
                                print("📱 [ReportExtension] Found \(count) items in \(label)")
                            }
                        }
                    }
                }
                
                // Only add to totals if we found real data
                if segmentDuration > 0 {
                    totalDuration += segmentDuration
                    print("✅ [ReportExtension] Added \(segmentDuration) seconds from real data")
                }
                
                if segmentAppCount > 0 {
                    appCount += segmentAppCount
                    print("✅ [ReportExtension] Added \(segmentAppCount) apps from real data")
                }
            }
        } catch {
            print("❌ [ReportExtension] Error processing activity data: \(error)")
        }
        
        guard hasData else {
            print("📊 [ReportExtension] No activity data available yet – waiting for sealed buckets")
            return
        }
        
        let minutes = Int(totalDuration / 60)
        let usageScore = max(0, 100 - ((minutes / 30) * 10))
        
        print("📊 [ReportExtension] Aggregated real data: \(minutes) minutes, \(appCount) apps")
        
        // Update the UI state with real data
        await MainActor.run {
            self.totalScreenTime = totalDuration
            self.monitoredAppsCount = appCount
            self.activityScore = usageScore
            self.isProcessing = false
        }
        
        if let sharedDefaults = UserDefaults(suiteName: "group.com.doomscroll.shared") {
            sharedDefaults.set(totalDuration, forKey: "totalScreenTime")
            sharedDefaults.set(appCount, forKey: "totalAppCount")
            sharedDefaults.set(Date(), forKey: "lastScreenTimeUpdate")
            sharedDefaults.set(usageScore, forKey: "usageScore")
            // Timestamp to notify main app of fresh data
            sharedDefaults.set(Date().timeIntervalSince1970, forKey: "dataUpdateTimestamp")
            sharedDefaults.synchronize()
            print("📊 [ReportExtension] Stored aggregate data successfully")
        } else {
            print("❌ [ReportExtension] Failed to access shared UserDefaults")
        }
    }
    

}

// MARK: - DeviceActivityReport Scene
struct TotalActivityReport: DeviceActivityReportScene {
    typealias Configuration = DeviceActivityResults<DeviceActivityData>
    typealias Content = TotalActivityView
    
    let context: DeviceActivityReport.Context = .totalActivity
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> Configuration {
        return data
    }
    
    var content: (Configuration) -> Content {
        return { configuration in
            TotalActivityView(totalActivity: configuration)
        }
    }
} 