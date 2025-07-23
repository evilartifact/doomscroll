import SwiftUI
import DeviceActivity

struct HiddenActivityCollector: View {
    // Get the manager from the environment
    @EnvironmentObject var screenTimeManager: ScreenTimeManager

    var body: some View {
        // Use the manager's function to create the filter.
        // This is the key that connects your app's selections to the report.
        if let filter = screenTimeManager.createDeviceActivityFilter() {
            
            // Create the report view. The act of creating this view is what
            // tells the system to run your report extension.
            DeviceActivityReport(.totalActivity, filter: filter)
            
                // Keep the view completely hidden from the user interface.
                .frame(width: 0, height: 0)
                .opacity(0)
        }
    }
}
