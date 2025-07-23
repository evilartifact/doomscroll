import SwiftUI
import FamilyControls
import DeviceActivity
import os.log

struct ScreenTimeView: View {
    @StateObject private var viewModel = ScreenTimeViewModel()
    private let logger = Logger(subsystem: "llc.doomscroll", category: "ScreenTimeView")
    @State private var isLoading = true
    @State private var loadingTimer: Timer? = nil
    @State private var elapsedTime = 0
    
    var body: some View {
        VStack {
            if viewModel.hasPermission {
                ZStack {
                    DeviceActivityReporterAdapter()
                        .opacity(isLoading ? 0 : 1) // Hide until data is loaded
                    
                    // Loading indicator
                    if isLoading {
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                            
                            Text("Preparing Screen Time Data")
                                .font(.headline)
                            
                            Text("This may take up to 30 seconds on first launch")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
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
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("Screen Time Permission Required")
                        .font(.headline)

                    Text("This feature requires permission to access your screen time data.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button("Grant Permission") {
                        logger.info("📊 Permission request button tapped")
                        viewModel.requestPermission()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
                .padding()
                .onAppear {
                    logger.info("📊 Permission NOT granted, showing permission request view")
                }
            }
        }
        .navigationTitle("Screen Time")
        .onAppear {
            logger.info("📊 ScreenTimeView appeared, hasPermission: \(viewModel.hasPermission)")
            viewModel.checkPermissionAndLoadData()
            startLoadingTimer()
        }
        .onChange(of: viewModel.hasPermission) { newValue in
            logger.info("📊 Permission status changed to: \(newValue)")
        }
    }
    
    private func startLoadingTimer() {
        // Reset elapsed time
        elapsedTime = 0
        isLoading = true
        
        // Cancel any existing timer
        loadingTimer?.invalidate()
        
        // Create a new timer that fires every second
        loadingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime += 1
            
            // After 30 seconds, hide the loading indicator
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

}

class ScreenTimeViewModel: ObservableObject {
    private let logger = Logger(subsystem: "llc.doomscroll", category: "ScreenTimeViewModel")
    @Published var hasPermission = false
    
    private let requestAuth = RequestAuthorization()
    
    init() {
        logger.info("📊 ScreenTimeViewModel initialized")
        let status = AuthorizationCenter.shared.authorizationStatus
        logger.info("📊 Initial permission status: \(status == .approved ? "approved" : "not approved")")
    }
    
    func checkPermissionAndLoadData() {
        logger.info("📊 checkPermissionAndLoadData called")
        Task {
            await checkPermission()
        }
    }
    
    func requestPermission() {
        logger.info("📊 requestPermission called")
        Task {
            logger.info("📊 Requesting FamilyControls permission")
            let granted = await requestAuth.requestFamilyControls(for: .individual)
            logger.info("📊 Permission request result: \(granted)")
            await MainActor.run {
                self.hasPermission = granted
                logger.info("📊 Updated hasPermission to: \(granted)")
            }
        }
    }
    
    func checkPermission() async {
        logger.info("📊 checkPermission called")
        let status = AuthorizationCenter.shared.authorizationStatus
        logger.info("📊 Current permission status: \(status)")
        await MainActor.run {
            self.hasPermission = (status == .approved)
            logger.info("📊 Updated hasPermission to: \(status == .approved)")
            
            // Check if shared UserDefaults contains data across multiple app group IDs
            let appGroupIds = ["group.llc.doomscroll.shared", "group.llc.doomscroll.shared", "group.llc.doomscroll"]
            var foundData = false
            
            for appGroupId in appGroupIds {
                logger.info("📊 Checking shared UserDefaults with group ID: \(appGroupId)")
                
                if let sharedDefaults = UserDefaults(suiteName: appGroupId) {
                    // Check for extension initialization markers
                    if let lastRun = sharedDefaults.object(forKey: "extensionLastRun") as? Date {
                        let formatter = DateFormatter()
                        formatter.dateStyle = .short
                        formatter.timeStyle = .medium
                        logger.info("📊 Found extension last run in shared UserDefaults: \(formatter.string(from: lastRun))")
                        foundData = true
                    }
                    
                    // integer(forKey:) returns Int not Optional Int
                    let initCount = sharedDefaults.integer(forKey: "extensionInitCount")
                    logger.info("📊 Extension initialization count: \(initCount)")
                    
                    // Check for actual screen time data
                    if let totalTime = sharedDefaults.object(forKey: "totalScreenTime") as? TimeInterval {
                        logger.info("📊 Found totalScreenTime in shared UserDefaults: \(totalTime) seconds")
                        foundData = true
                    } else {
                        logger.warning("⚠️ No totalScreenTime found in shared UserDefaults with group ID: \(appGroupId)")
                    }
                    
                    if let appReportsData = sharedDefaults.data(forKey: "appReportsData") {
                        if let appReports = try? JSONDecoder().decode([AppReport].self, from: appReportsData) {
                            logger.info("📊 Successfully decoded \(appReports.count) app reports from shared UserDefaults with group ID: \(appGroupId)")
                            foundData = true
                        } else {
                            logger.error("❌ Failed to decode app reports from shared UserDefaults with group ID: \(appGroupId)")
                        }
                    } else {
                        logger.warning("⚠️ No appReportsData found in shared UserDefaults with group ID: \(appGroupId)")
                    }
                    
                    // Write a test value to verify we can write to this app group
                    sharedDefaults.set("Test from main app at \(Date())", forKey: "mainAppTest")
                    sharedDefaults.synchronize()
                    logger.info("📊 Wrote test value to shared UserDefaults with group ID: \(appGroupId)")
                } else {
                    logger.error("❌ Failed to access shared UserDefaults with group ID: \(appGroupId)")
                }
            }
            
            if !foundData {
                logger.error("❌ No data found in any shared UserDefaults group")
            }
        }
    }
}

struct ScreenTimeView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenTimeView()
    }
}
