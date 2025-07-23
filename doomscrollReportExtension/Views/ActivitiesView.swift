
import SwiftUI
import os.log

struct ActivitiesView: View {
    private let logger = Logger(subsystem: "llc.doomscroll.doomscrollReportExtension", category: "ActivitiesView")
    var activities: DeviceActivity
    
    init(activities: DeviceActivity) {
        self.activities = activities
        logger.info("📊 ActivitiesView initialized with activities: \(activities.duration) seconds, \(activities.apps.count) apps")
        if activities.apps.isEmpty {
            logger.warning("⚠️ ActivitiesView initialized with EMPTY apps array")
        }
    }
    
    var body: some View {
        // Log outside of the view hierarchy
        let _ = { logger.info("📊 ActivitiesView body called") }()
        let sortedApps = activities.apps.sorted { $0.duration > $1.duration }
        let _ = { logger.info("📊 Sorted apps count: \(sortedApps.count)") }()
        
        return VStack(spacing: 0) {
            // Header with total usage time
            VStack(spacing: 8) {
                Text("Screen Time")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(activities.duration.toScreenTimeString())
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                
                Text("Today")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .padding(.horizontal)
            .padding(.top, 16)
            
            // App usage section
            VStack(alignment: .leading, spacing: 8) {
                Text("Most Used Apps")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                if sortedApps.isEmpty {
                    // Log outside of the view hierarchy
                    let _ = { logger.warning("⚠️ Displaying empty state - no apps to show") }()
                    VStack(spacing: 12) {
                        Image(systemName: "hourglass")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No app usage data yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("App usage will appear here once collected")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    // Log outside of the view hierarchy
                    let _ = { logger.info("📊 Displaying list with \(sortedApps.count) apps") }()
                    List {
                        ForEach(sortedApps) { app in
                            ListItem(app: app)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .background(Color.clear)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            logger.info("📊 ActivitiesView appeared")
            if sortedApps.isEmpty {
                logger.warning("⚠️ ActivitiesView appeared with empty apps array")
            } else {
                logger.info("📊 Top app: \(sortedApps.first?.name ?? "none") with \(sortedApps.first?.duration ?? 0) seconds")
            }
        }
    }
}

struct ActivitiesView_Previews: PreviewProvider {
    static var previews: some View {
        ActivitiesView(activities: DeviceActivity(
            duration: 3600 * 4 + 1800,
            apps: [
                AppReport(id: "com.twitter.ios", name: "Twitter", duration: 3600),
                AppReport(id: "com.instagram.ios", name: "Instagram", duration: 1800),
                AppReport(id: "com.facebook.ios", name: "Facebook", duration: 900)
            ]
        ))
    }
}
