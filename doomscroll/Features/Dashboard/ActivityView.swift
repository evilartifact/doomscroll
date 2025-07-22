//
//  ActivityView.swift
//  doomscroll
//
//  Created by Rabin on 7/22/25.
//

import SwiftUI
import Foundation

// UI-Only ActivityView that reads data collected by MonitorExtension
struct ActivityView: View {
    @State private var totalScreenTime: TimeInterval = 0
    @State private var monitoredAppsCount: Int = 0
    @State private var activityScore: Int = 50
    @State private var isLoading: Bool = true
    @State private var lastUpdated: Date?
    
    // Timer to refresh data periodically
    let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
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
                    Text("\(monitoredAppsCount)")
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
                    Text("\(activityScore)/100")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Status indicator
                HStack {
                    Circle()
                        .fill(isLoading ? Color.orange : Color.green)
                        .frame(width: 8, height: 8)
                    Text(isLoading ? "Loading data..." : "Data from MonitorExtension")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    
                    if let lastUpdated = lastUpdated {
                        Text("Updated: \(lastUpdated, formatter: timeFormatter)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .padding()
            .background(Color.black.opacity(0.1))
            .cornerRadius(12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onAppear {
            loadDataFromMonitorExtension()
        }
        .onReceive(timer) { _ in
            loadDataFromMonitorExtension()
        }
    }
    
    // MARK: - Data Loading from MonitorExtension
    
    private func loadDataFromMonitorExtension() {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.doomscroll.shared") else {
            print("❌ [ActivityView] Failed to access shared UserDefaults")
            return
        }
        
        // Read data written by MonitorExtension
        let totalTime = sharedDefaults.double(forKey: "totalScreenTime")
        let appCount = sharedDefaults.integer(forKey: "totalAppCount")
        let score = sharedDefaults.integer(forKey: "usageScore")
        let updateTimestamp = sharedDefaults.double(forKey: "dataUpdateTimestamp")
        
        // Update UI state
        if totalTime > 0 || appCount > 0 {
            totalScreenTime = totalTime
            monitoredAppsCount = appCount
            activityScore = score > 0 ? score : 50
            isLoading = false
            
            if updateTimestamp > 0 {
                lastUpdated = Date(timeIntervalSince1970: updateTimestamp)
            }
            
            print("✅ [ActivityView] Loaded data: \(Int(totalTime/60))m, \(appCount) apps, score: \(score)")
        } else {
            // No data yet - keep loading state
            print("📊 [ActivityView] No data available yet from MonitorExtension")
        }
    }
    
    // MARK: - UI Helpers
    
    private func formatTotalTime() -> String {
        if isLoading {
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
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    ActivityView()
        .frame(height: 200)
}
