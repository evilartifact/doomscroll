import SwiftUI



struct testView: View {
    // State to manage the sheet's vertical position
    @State private var offset: CGFloat = 0
    @State private var lastOffset: CGFloat = 0

    // State variables for the sheet's controls
    @State private var isNotificationsEnabled = true
    @State private var isCloudSyncEnabled = false
    @State private var brightnessLevel: Double = 0.8

    var body: some View {
        GeometryReader { geometry in
            // Usable height is the total screen area minus the top and bottom safe areas.
            let usableHeight = geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
            
            // The starting and minimum position (50% of the usable screen area).
            let midPosition = usableHeight / 2
            
            // The highest position the sheet can go. A smaller positive value means higher up.
            // We leave a small gap from the very top for better aesthetics.
            let topPosition = -midPosition// Goes higher than before.

            ZStack(alignment: .bottom) {
                // MARK: - Main Content (Bottom Layer)
                NavigationView {
                    List {
                        Section(header: Text("General")) {
                            HStack { Image(systemName: "person.circle.fill"); Text("Account") }
                            HStack { Image(systemName: "globe"); Text("Language") }
                            HStack { Image(systemName: "info.circle"); Text("About") }
                        }
                        Section(header: Text("Advanced")) {
                            HStack { Image(systemName: "gearshape.2.fill"); Text("Advanced Settings") }
                            HStack { Image(systemName: "lock.shield.fill"); Text("Privacy & Security") }
                        }
                    }
                    .navigationTitle("Settings")
                }

                // MARK: - Draggable Sheet (Top Layer)
                VStack {
                    // Drag Handle
                    Capsule()
                        .frame(width: 40, height: 6)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)

                    // Sheet Content
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Display & Quick Actions")
                            .font(.title2).fontWeight(.bold)
                        VStack {
                            Toggle(isOn: $isNotificationsEnabled) {
                                Label("Enable Notifications", systemImage: "bell.badge.fill")
                            }
                            Toggle(isOn: $isCloudSyncEnabled) {
                                Label("Enable Cloud Sync", systemImage: "cloud.fill")
                            }
                        }
                        Divider()
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Screen Brightness", systemImage: "sun.max.fill")
                            Slider(value: $brightnessLevel, in: 0...1)
                            Text("Level: \(String(format: "%.2f", brightnessLevel))")
                                .font(.caption).foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Frame is based on usable height
                .background(.regularMaterial)
                .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
                .ignoresSafeArea(edges: .bottom)
                .shadow(radius: 5)
                .offset(y: midPosition)
                .offset(y: offset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            let newOffset = gesture.translation.height + self.lastOffset
                            // Clamp the offset between the top position and the minimum (0).
                            self.offset = max(topPosition, min(newOffset, 0))
                        }
                        .onEnded { gesture in
                            withAnimation(.easeOut(duration: 0.3)) {
                                // Snap to top or middle based on position
                                if self.offset < -100 {
                                    self.offset = topPosition
                                } else {
                                    self.offset = 0
                                }
                            }
                            self.lastOffset = self.offset
                        }
                )
            }
            // By NOT ignoring the bottom safe area, we ensure the ZStack respects the tab bar.
        }
    }
}
