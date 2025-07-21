//
//  BlockingViewContent.swift
//  doomscroll
//
//  Created by Rabin on 7/10/25.
//

import SwiftUI
import FamilyControls
import DeviceActivity



// MARK: - BlockingViewContent
struct BlockingViewContent: View {
    let isExpanded: Bool
    @StateObject private var screenTimeManager = ScreenTimeManager()
    @StateObject private var dataManager = DataManager.shared
    @State private var showingAppPicker = false
    @State private var showingNewRule = false
    @State private var showingEmergencyAccess = false
    @State private var showingStopBlockingSheet = false
    @State private var selectedMinutes = 30
    
    var body: some View {
        if isExpanded {
            ScrollView(showsIndicators: false) {
                expandedView
                    .padding(.bottom, 100)
            }
        } else {
            compactView
        }
    }
    
    // MARK: - Compact View (Default State)
    private var compactView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Text("App Blocking")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            if screenTimeManager.authorizationStatus != .approved {
                // Authorization needed - compact
                HStack(spacing: 12) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.orange)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Permission Required")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Tap to grant Screen Time access")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    DSButton("Grant", style: .primary, size: .medium) {
                        Task {
                            await screenTimeManager.requestAuthorization()
                        }
                    }
                }
                .padding(16)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            } else {
                // Main status row
                HStack(spacing: 12) {
                    // Status indicator
                    Circle()
                        .fill(screenTimeManager.isBlocking ? Color.red : Color.green)
                        .frame(width: 10, height: 10)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(screenTimeManager.isBlocking ? "Active" : "Inactive")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        if screenTimeManager.isBlocking && !screenTimeManager.screenTimeSelection.applicationTokens.isEmpty {
                            Text("\(screenTimeManager.screenTimeSelection.applicationTokens.count) apps")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.8))
                        } else if !screenTimeManager.isBlocking && !screenTimeManager.screenTimeSelection.applicationTokens.isEmpty {
                            Text("\(screenTimeManager.screenTimeSelection.applicationTokens.count) apps ready")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                        } else {
                            Text("No apps selected")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    
                    Spacer()
                    
                    // Overlapping app icons - only show when blocking
                    if screenTimeManager.isBlocking && !screenTimeManager.screenTimeSelection.applicationTokens.isEmpty {
                        Button(action: {
                            showingAppPicker = true
                        }){
                            overlappingAppIcons
                        }
                    } else if !screenTimeManager.isBlocking && !screenTimeManager.screenTimeSelection.applicationTokens.isEmpty {
                        Button(action: {
                            showingAppPicker = true
                        }){
                            overlappingAppIcons
                        }
                    } else {
                        DSButtonCompact(
                            "+",
                            style: .primary,
                            size: .medium
                        ) {
                            showingAppPicker = true
                        }

                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.02))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                VStack(spacing: 16){
                    
                // Action buttons row
                HStack(spacing: 12) {
                    if !screenTimeManager.screenTimeSelection.applicationTokens.isEmpty {
                        DSButton(
                            screenTimeManager.isBlocking ? "Stop Blocking" : "Start Blocking",
                            style: screenTimeManager.isBlocking ? .danger : .success,
                            size: .medium
                        ) {
                            if screenTimeManager.isBlocking {
                                showingStopBlockingSheet = true
                            } else {
                                Task {
                                    await screenTimeManager.blockSelectedApps()
                                }
                            }
                        }
                    }

                    
                    if screenTimeManager.isBlocking {
                        DSButton("Emergency", style: .warning, size: .medium) {
                            showingEmergencyAccess = true
                        }
                    }
                }
                .padding(.bottom, 8)
                
                // Blocking rules quick access
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Blocking Rules")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        if dataManager.blockingRules.isEmpty {
                            Text("No rules created yet")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                        } else {
                            Text("\(dataManager.blockingRules.count) rule\(dataManager.blockingRules.count == 1 ? "" : "s") active")
                                .font(.system(size: 12))
                                .foregroundColor(.orange.opacity(0.8))
                        }
                    }
                    
                    Spacer()
                    
                    DSButtonCompact(
                        "Create Rule",
                        style: .danger,
                        size: .medium
                    ) {
                        showingNewRule = true
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.02))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
            }
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 16)
        .familyActivityPicker(isPresented: $showingAppPicker, selection: $screenTimeManager.screenTimeSelection)
        .onChange(of: screenTimeManager.screenTimeSelection) { selection in
            screenTimeManager.updateSelectedApps(selection)
        }
        .dsSheet(title: "Emergency Access", isPresented: $showingEmergencyAccess) {
            EmergencyAccessView(isPresented: $showingEmergencyAccess)
        }
        .dsSheet(title: "Stop Blocking?", isPresented: $showingStopBlockingSheet) {
            StopBlockingReasonSheet(isPresented: $showingStopBlockingSheet)
        }
    }
    
    // MARK: - Overlapping App Icons
    private var overlappingAppIcons: some View {
        HStack(spacing: -12) {
            ForEach(Array(screenTimeManager.screenTimeSelection.applicationTokens.prefix(5).enumerated()), id: \.offset) { index, token in
                Label(token)
                    .labelStyle(.iconOnly)
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                    )
                    .zIndex(Double(5 - index))
            }
            
            if screenTimeManager.screenTimeSelection.applicationTokens.count > 5 {
                Text("+\(screenTimeManager.screenTimeSelection.applicationTokens.count - 5)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
        }
    }
    
    // MARK: - Expanded View (Full Details)
    private var expandedView: some View {
            VStack(spacing: 24) {
                headerSection
                authorizationSection
                currentStatusSection
                appSelectionSection
                quickActionsSection
                emergencyAccessSection
                blockingRulesSection
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 12)
        .familyActivityPicker(isPresented: $showingAppPicker, selection: $screenTimeManager.screenTimeSelection)
        .onChange(of: screenTimeManager.screenTimeSelection) { selection in
            screenTimeManager.updateSelectedApps(selection)
        }
        .dsSheet(title: "Emergency Access", isPresented: $showingEmergencyAccess) {
            EmergencyAccessView(isPresented: $showingEmergencyAccess)
        }
        .dsSheet(title: "Stop Blocking?", isPresented: $showingStopBlockingSheet) {
            StopBlockingReasonSheet(isPresented: $showingStopBlockingSheet)
        }
    }
    
    private var headerSection: some View {
        HStack(spacing: 8) {
            Text("App Blocking")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.top, 20)
    }
    
    private var authorizationSection: some View {
        Group {
            if screenTimeManager.authorizationStatus != .approved {
                VStack(spacing: 16) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    
                    Text("Screen Time Permission Required")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("To block apps, we need permission to access Screen Time controls.")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    DSButton(
                        "Grant Permission",
                        style: .primary,
                        size: .medium
                    ) {
                        Task {
                            await screenTimeManager.requestAuthorization()
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.02))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )

            }
        }
    }
    
    private var currentStatusSection: some View {
        Group {
            if screenTimeManager.authorizationStatus == .approved {
                HStack(spacing: 12) {
                    // Status indicator
                    Circle()
                        .fill(screenTimeManager.isBlocking ? Color.red : Color.green)
                        .frame(width: 10, height: 10)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(screenTimeManager.isBlocking ? "Blocking Active" : "Blocking Inactive")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        if screenTimeManager.isBlocking && !screenTimeManager.screenTimeSelection.applicationTokens.isEmpty {
                            Text("\(screenTimeManager.screenTimeSelection.applicationTokens.count) apps")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.8))
                        } else if !screenTimeManager.isBlocking && !screenTimeManager.screenTimeSelection.applicationTokens.isEmpty {
                            Text("\(screenTimeManager.screenTimeSelection.applicationTokens.count) apps ready")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                        } else {
                            Text("No apps selected")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    
                    Spacer()
                    
                    // Overlapping app icons - only show when blocking
                    if screenTimeManager.isBlocking && !screenTimeManager.screenTimeSelection.applicationTokens.isEmpty {
                        Button(action: {
                            showingAppPicker = true
                        }){
                            overlappingAppIcons
                        }
                    } else if !screenTimeManager.isBlocking && !screenTimeManager.screenTimeSelection.applicationTokens.isEmpty {
                        Button(action: {
                            showingAppPicker = true
                        }){
                            overlappingAppIcons
                        }
                    } else {
                        DSButtonCompact(
                            "+",
                            style: .primary,
                            size: .medium
                        ) {
                            showingAppPicker = true
                        }

                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.02))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )

            }
        }
    }

    
    private var appSelectionSection: some View {
        Group {
            if screenTimeManager.authorizationStatus == .approved {
                VStack(spacing: 16) {
                    
                    if !screenTimeManager.screenTimeSelection.applicationTokens.isEmpty {
                        DSButton(
                            screenTimeManager.isBlocking ? "Stop Blocking" : "Start Blocking",
                            style: screenTimeManager.isBlocking ? .danger : .success,
                            size: .medium
                        ) {
                            if screenTimeManager.isBlocking {
                                showingStopBlockingSheet = true
                            } else {
                                Task {
                                    await screenTimeManager.blockSelectedApps()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var quickActionsSection: some View {
        quickActionsContent
    }
    
    @ViewBuilder
    private var quickActionsContent: some View {
        if screenTimeManager.authorizationStatus == .approved && !screenTimeManager.screenTimeSelection.applicationTokens.isEmpty {
            VStack(spacing: 16) {
                quickBlockHeader
                durationPicker
                blockButton
            }
            .padding(20)
            .background(quickActionsBackground)
        }
    }
    
    private var quickBlockHeader: some View {
        Text("Quick Block")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var durationPicker: some View {
        Picker("Duration", selection: $selectedMinutes) {
            Text("15 min").tag(15)
            Text("30 min").tag(30)
            Text("1 hour").tag(60)
            Text("2 hours").tag(120)
        }
        .pickerStyle(SegmentedPickerStyle())
        .background(Color.white.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var blockButton: some View {
        DSButton(
            "Block for \(selectedMinutes) minutes",
            style: .warning,
            size: .medium
        ) {
            Task {
                await screenTimeManager.blockAppsForMinutes(selectedMinutes)
            }
        }
    }
    
    private var quickActionsBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.02))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
    
    private var emergencyAccessSection: some View {
        Group {
            if screenTimeManager.isBlocking {
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Emergency Access")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Temporarily disable blocking (costs XP)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                    }
                    
                    DSButton(
                        "Emergency Override",
                        style: .danger,
                        size: .medium
                    ) {
                        showingEmergencyAccess = true
                    }
                }
                .padding(20)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(20)
            }
        }
    }
    
    // MARK: - Blocking Rules Section
    private var blockingRulesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Blocking Rules")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            if dataManager.blockingRules.isEmpty {
                DSCard {
                    VStack(spacing: 12) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("No blocking rules yet")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Create rules to automatically block apps at specific times or conditions")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                        
                        DSButton(
                            "Create First Rule",
                            style: .danger,
                            size: .medium
                        ) {
                            showingNewRule = true
                        }
                    }
                    .padding(.vertical, 8)
                }
            } else {
                ForEach(dataManager.blockingRules) { rule in
                    BlockingRuleCard(rule: rule)
                }
            }
        }
    }
}


struct StopBlockingReasonSheet: View {
    @Binding var isPresented: Bool
    @StateObject private var screenTimeManager = ScreenTimeManager()
    @StateObject private var levelManager = LevelManager.shared
    
    @State private var selectedReason: String = ""
    
    private let reasons = [
        "I'm bored and need distraction",
        "I'm craving social media",
        "I need to check something important",
        "I want to message someone",
        "I'm feeling anxious",
        "I'm procrastinating on work",
        "I just want to scroll",
        "Other reason"
    ]
    
    var body: some View {
            VStack(spacing: 20) {
                // Warning icon and subtitle
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 40))
                    
                    Text("This will disable app blocking and cost you 10 Gems. Why do you want to stop?")
                        .font(.callout)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Reasons list
                VStack(spacing: 12) {
                    ForEach(reasons, id: \.self) { reason in
                        DSCard {
                            Button(action: {
                                selectedReason = reason
                            }) {
                                HStack {
                                    Image(systemName: selectedReason == reason ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedReason == reason ? .orange : .white.opacity(0.6))
                                        .font(.title3)
                                    
                                    Text(reason)
                                        .font(.callout)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                                .stroke(selectedReason == reason ? Color.orange : Color.clear, lineWidth: 2)
                        )
                    }
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    DSButton(
                        "Stop Blocking (-10 Gems)",
                        style: selectedReason.isEmpty ? .secondary : .danger,
                        size: .medium
                    ) {
                        if !selectedReason.isEmpty {
                            levelManager.deductGems(10, reason: "Stopped blocking: \(selectedReason)")
                            screenTimeManager.disableBlocking()
                            isPresented = false
                        }
                    }
                    .disabled(selectedReason.isEmpty)
                    
                    DSButton(
                        "Keep Blocking",
                        style: .success,
                        size: .medium
                    ) {
                        isPresented = false
                    }
                }
            }
            .padding(.horizontal, 22)
    }
}
