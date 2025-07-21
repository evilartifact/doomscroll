//
//  EmergencyAccessView.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import SwiftUI

struct EmergencyAccessView: View {
    @StateObject private var screenTimeManager = ScreenTimeManager()
    @StateObject private var levelManager = LevelManager.shared
    @Binding var isPresented: Bool
    
    @State private var selectedDuration: EmergencyDuration = .fiveMinutes
    @State private var reason: String = ""
    @State private var showingConfirmation = false
    
    var body: some View {
        
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.orange)
                            
                            Text("Emergency Access")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("This will temporarily disable app blocking but will cost you gems")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Duration Selection
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Duration")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 8) {
                                ForEach(EmergencyDuration.allCases, id: \.self) { duration in
                                    EmergencyDurationRow(
                                        duration: duration,
                                        isSelected: selectedDuration == duration
                                    ) {
                                        selectedDuration = duration
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Reason Input
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Reason (Optional)")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Why do you need emergency access?", text: $reason, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(2...4)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Cost Warning
                        HStack {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Gems Cost: \(selectedDuration.gemsCost)")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                
                                Text("Your current Gems: \(levelManager.currentGems)")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            DSButton(
                                "Grant Emergency Access",
                                style: .warning,
                                size: .medium
                            ) {
                                showingConfirmation = true
                            }
                            .disabled(levelManager.currentGems < selectedDuration.gemsCost)
                            .opacity(levelManager.currentGems < selectedDuration.gemsCost ? 0.5 : 1.0)
                            
                            DSButton(
                                "Cancel",
                                style: .secondary,
                                size: .medium
                            ) {
                                isPresented = false
                            }
                            
                            // Permanent Unblock Option
                            DSButton(
                                "Permanently Unblock All Apps",
                                style: .danger,
                                size: .medium
                            ) {
                                screenTimeManager.disableBlocking()
                                isPresented = false
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
        .alert("Confirm Emergency Access", isPresented: $showingConfirmation) {
            Button("Grant Access", role: .destructive) {
                grantEmergencyAccess()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will cost you \(selectedDuration.gemsCost) Gems and disable app blocking for \(selectedDuration.displayName).")
        }
    }
    
    private func grantEmergencyAccess() {
        // Deduct Gems
        levelManager.deductGems(selectedDuration.gemsCost, reason: "Emergency access (\(selectedDuration.displayName))")
        
        // Record social media use
        levelManager.recordSocialMediaUse()
        
        // Grant temporary access
        screenTimeManager.activateEmergencyOverride()
        
        // Log the reason if provided
        if !reason.isEmpty {
            // Could save this to analytics or logs
            print("Emergency access reason: \(reason)")
        }
        
        isPresented = false
    }
}

struct EmergencyDurationRow: View {
    let duration: EmergencyDuration
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .green : .white.opacity(0.6))
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(duration.displayName)
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text("\(duration.gemsCost) Gems cost")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Text(duration.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(isSelected ? Color.white.opacity(0.1) : Color.clear)
            .cornerRadius(8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

enum EmergencyDuration: CaseIterable {
    case fiveMinutes
    case tenMinutes
    case fifteenMinutes
    case thirtyMinutes
    
    var displayName: String {
        switch self {
        case .fiveMinutes: return "5 Minutes"
        case .tenMinutes: return "10 Minutes"
        case .fifteenMinutes: return "15 Minutes"
        case .thirtyMinutes: return "30 Minutes"
        }
    }
    
    var minutes: Int {
        switch self {
        case .fiveMinutes: return 5
        case .tenMinutes: return 10
        case .fifteenMinutes: return 15
        case .thirtyMinutes: return 30
        }
    }
    
    var gemsCost: Int {
        switch self {
        case .fiveMinutes: return 5
        case .tenMinutes: return 15
        case .fifteenMinutes: return 30
        case .thirtyMinutes: return 60
        }
    }
    
    var description: String {
        switch self {
        case .fiveMinutes: return "Quick check"
        case .tenMinutes: return "Brief usage"
        case .fifteenMinutes: return "Short session"
        case .thirtyMinutes: return "Extended use"
        }
    }
}

#Preview {
    EmergencyAccessView(isPresented: .constant(true))
} 
