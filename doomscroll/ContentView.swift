import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    @EnvironmentObject var notificationDelegate: NotificationDelegate
    @EnvironmentObject var screenTimeManager: ScreenTimeManager // <-- 1. ADD THIS LINE

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                    .ignoresSafeArea()
                CustomTabBarView()
                    .environmentObject(dataManager)
            }
            .background(
                BlockingDetectionView()
            )
            .background(
                // This view will now run in the background and trigger your report extension
                HiddenActivityCollector()
            )
            .dsSheet(
                title: "Unblock Decision",
                isPresented: $notificationDelegate.showingUnblockDecision
            ) {
                UnblockDecisionView(
                    isPresented: $notificationDelegate.showingUnblockDecision,
                    appName: notificationDelegate.requestedAppName
                )
            }
        }
    }
}


struct CustomTabBarView: View {
    @State private var selectedTab: Int = 0
    
    let tabImages = ["tab1", "tab2", "tab3", "tab4", "tab5"]
    let views: [AnyView] = [
        AnyView(DashboardView()),
        AnyView(JournalTasksView()), // Journal and task manager tab
        AnyView(AnalyticsView()),
        AnyView(EducationView()),
        AnyView(SettingsView())
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content
            views[selectedTab]
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Rectangle()
                    .fill(Color(UIColor.systemGray5))
                    .frame(height: 1)
                    .edgesIgnoringSafeArea(.horizontal)
            
            
            // Custom Tab Bar
            HStack(spacing: 0) {
                ForEach(0..<tabImages.count, id: \.self) { idx in
                    Spacer()
                    Button {
                        selectedTab = idx
                    } label: {
                        ZStack {
                            // Selected style
                            if selectedTab == idx {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.blue, lineWidth: 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(Color.blue.opacity(0.2))
                                    )
                                    .frame(width: 44, height: 44)
                            }                            // Image
                            Image(tabImages[idx])
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                        .frame(width: 48, height: 48)
                    }
                    Spacer()
                }
            }
            .padding(.vertical, 6)
        }
    }
}



#Preview {
    ContentView()
}
