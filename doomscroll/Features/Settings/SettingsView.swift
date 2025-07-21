//
//  SettingsView.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var learningManager: LearningManager
    @State private var showAbout = false
    @State private var showDataExport = false
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()
                
                ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    
                    // Settings sections
                    notificationsSection
                    dataSection
                    debugSection
                    supportSection
                    aboutSection
                }
                .padding(DesignSystem.Spacing.md)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .dsSheet(title: "About", isPresented: $showAbout) {
            AboutView(isPresented: $showAbout)
        }
        .dsSheet(title: "Export Data", isPresented: $showDataExport) {
            DataExportView(isPresented: $showDataExport)
        }
    }

    
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Notifications")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            DSCard {
                VStack(spacing: DesignSystem.Spacing.md) {
                    settingsRow(
                        title: "Daily Reminders",
                        subtitle: "Get reminded to check your mood",
                        icon: "bell.fill",
                        color: DesignSystem.Colors.primary
                    ) {
                        Toggle("", isOn: .constant(true))
                            .toggleStyle(SwitchToggleStyle(tint: DesignSystem.Colors.primary))
                    }
                    
                    Divider()
                        .background(DesignSystem.Colors.cardBorder)
                    
                    settingsRow(
                        title: "Urge Notifications",
                        subtitle: "Helpful reminders when you're struggling",
                        icon: "heart.fill",
                        color: DesignSystem.Colors.warning
                    ) {
                        Toggle("", isOn: .constant(false))
                            .toggleStyle(SwitchToggleStyle(tint: DesignSystem.Colors.primary))
                    }
                }
            }
        }
    }
    
    private var dataSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Data")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            DSCard {
                VStack(spacing: DesignSystem.Spacing.md) {
                    settingsRow(
                        title: "Export Data",
                        subtitle: "Download your mood and urge data",
                        icon: "square.and.arrow.up.fill",
                        color: DesignSystem.Colors.success
                    ) {
                        Button("Export") {
                            showDataExport = true
                        }
                    }
                    
                    Divider()
                        .background(DesignSystem.Colors.cardBorder)
                    
                    settingsRow(
                        title: "Clear All Data",
                        subtitle: "Permanently delete all your data",
                        icon: "trash.fill",
                        color: DesignSystem.Colors.danger
                    ) {
                        Button("Clear") {
                            // Clear data functionality
                        }
                    }
                }
            }
        }
    }
    
    private var debugSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Debug")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            DSCard {
                VStack(spacing: DesignSystem.Spacing.md) {
                    settingsRow(
                        title: "Reset Chapter Progress",
                        subtitle: "Reset your progress in all chapters",
                        icon: "arrow.counterclockwise.circle.fill",
                        color: DesignSystem.Colors.primary
                                         ) {
                         Button("Reset") {
                             learningManager.resetProgress()
                         }
                     }
                    
                    Divider()
                        .background(DesignSystem.Colors.cardBorder)
                    
                    settingsRow(
                        title: "View Chapter Status",
                        subtitle: "Check your progress in all chapters",
                        icon: "eye.fill",
                        color: DesignSystem.Colors.primary
                    ) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                }
            }
        }
    }
    
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Support")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            DSCard {
                VStack(spacing: DesignSystem.Spacing.md) {
                    settingsRow(
                        title: "Help & FAQ",
                        subtitle: "Get help with using the app",
                        icon: "questionmark.circle.fill",
                        color: DesignSystem.Colors.primary
                    ) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                    
                    Divider()
                        .background(DesignSystem.Colors.cardBorder)
                    
                    settingsRow(
                        title: "Contact Support",
                        subtitle: "Get in touch with our team",
                        icon: "envelope.fill",
                        color: DesignSystem.Colors.success
                    ) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                }
            }
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("About")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            DSCard {
                VStack(spacing: DesignSystem.Spacing.md) {
                    settingsRow(
                        title: "Version",
                        subtitle: "1.0.0 (Phase 1)",
                        icon: "info.circle.fill",
                        color: DesignSystem.Colors.primary
                    ) {
                        EmptyView()
                    }
                    
                    Divider()
                        .background(DesignSystem.Colors.cardBorder)
                    
                    settingsRow(
                        title: "Privacy Policy",
                        subtitle: "How we protect your data",
                        icon: "lock.fill",
                        color: DesignSystem.Colors.warning
                    ) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                    
                    Divider()
                        .background(DesignSystem.Colors.cardBorder)
                    
                    Button(action: {
                        showAbout = true
                    }) {
                        settingsRow(
                            title: "About This App",
                            subtitle: "Learn more about DoomScroll Blocker",
                            icon: "heart.fill",
                            color: DesignSystem.Colors.danger
                        ) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private func settingsRow<Content: View>(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        @ViewBuilder trailing: () -> Content
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text(subtitle)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            Spacer()
            
            trailing()
        }
    }
}

// Placeholder views
struct AboutView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.title)
                .foregroundColor(DesignSystem.Colors.primary)
            
            Text("DoomScroll Blocker")
                .font(DesignSystem.Typography.title)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Text("This app helps you break free from the cycle of mindless scrolling and take control of your digital habits.")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            Text("Phase 1 includes basic mood tracking, urge logging, and the foundation for app blocking features.")
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.textTertiary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}

struct DataExportView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "square.and.arrow.up.fill")
                .font(.title)
                .foregroundColor(DesignSystem.Colors.success)
            
            Text("Export Your Data")
                .font(DesignSystem.Typography.title)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Text("Data export functionality will be available in Phase 2. This will allow you to download all your mood entries and urge logs.")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            DSButton("Close") {
                isPresented = false
            }
        }
        .padding()
    }
}

#Preview {
    SettingsView()
        .environmentObject(DataManager.shared)
        .environmentObject(LearningManager.shared)
} 
