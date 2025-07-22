import SwiftUI

// This view is no longer needed since MonitorExtension handles all data collection automatically
// MonitorExtension collects data when DeviceActivity intervals trigger, no UI component needed
struct HiddenActivityCollector: View {
    var body: some View {
        // Empty view - MonitorExtension handles all data collection
        EmptyView()
    }
}
