//
//  NewBlockingRuleView.swift
//  doomscroll
//
//  Created by Rabin on 7/10/25.
//
import SwiftUI
import FamilyControls
import DeviceActivity


struct NewBlockingRuleView: View {
    @Binding var isPresented: Bool
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var screenTimeManager = ScreenTimeManager()
    @State private var ruleName = ""
    @State private var selectedDifficulty: AppBlockingRule.DifficultyLevel = .moderate
    @State private var selectedSchedule: AppBlockingRule.BlockingSchedule = .always
    
    var body: some View {
        VStack(spacing: 24) {
            // Rule Details Section
            DSCard {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Rule Details")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rule Name")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        TextField("Enter rule name", text: $ruleName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Difficulty Level")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        VStack(spacing: 8) {
                            ForEach(AppBlockingRule.DifficultyLevel.allCases, id: \.self) { difficulty in
                                Button(action: {
                                    selectedDifficulty = difficulty
                                }) {
                                    HStack {
                                        Text(difficulty.emoji)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(difficulty.name)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.white)
                                            Text(difficulty.description)
                                                .font(.system(size: 12))
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        Spacer()
                                        if selectedDifficulty == difficulty {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        } else {
                                            Circle()
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                                .frame(width: 20, height: 20)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(selectedDifficulty == difficulty ? Color.white.opacity(0.1) : Color.clear)
                                    .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            
            // Schedule Section
            DSCard {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Schedule")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 8) {
                        ScheduleOptionButton(
                            title: "Always Active",
                            description: "Block apps continuously",
                            isSelected: isAlwaysSelected,
                            action: { selectedSchedule = .always }
                        )
                        
                        ScheduleOptionButton(
                            title: "Work Hours",
                            description: "Block apps from 9 AM to 5 PM daily",
                            isSelected: isWorkHoursSelected,
                            action: { selectedSchedule = .dailyTimeRange(startHour: 9, startMinute: 0, endHour: 17, endMinute: 0) }
                        )
                        
                        ScheduleOptionButton(
                            title: "Weekdays Only",
                            description: "Block apps Monday through Friday",
                            isSelected: isWeekdaysSelected,
                            action: { selectedSchedule = .weekdays([.monday, .tuesday, .wednesday, .thursday, .friday]) }
                        )
                    }
                }
                .padding(.vertical, 4)
            }
            
            // Apps Section
            DSCard {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Apps to Block")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if screenTimeManager.screenTimeSelection.applicationTokens.isEmpty {
                        Text("Please select apps to block using the app picker above.")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                    } else {
                        Text("\(screenTimeManager.screenTimeSelection.applicationTokens.count) apps will be used for this rule")
                            .font(.system(size: 14))
                            .foregroundColor(.orange.opacity(0.8))
                        .multilineTextAlignment(.center)
                    }
                }
                .padding(.vertical, 4)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 12) {
                DSButton(
                    "Create Rule",
                    style: .primary,
                    size: .medium
                ) {
                    let newRule = AppBlockingRule(
                        name: ruleName.isEmpty ? "New Rule" : ruleName,
                        isEnabled: true,
                        blockedApps: [], // We could store app bundle identifiers if needed
                        schedule: selectedSchedule,
                        difficultyLevel: selectedDifficulty,
                        createdDate: Date(),
                        lastModified: Date()
                    )
                    dataManager.addBlockingRule(newRule)
                    isPresented = false
                }
                .disabled(ruleName.isEmpty)
                
                DSButton(
                    "Cancel",
                    style: .secondary,
                    size: .medium
                ) {
                    isPresented = false
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var isAlwaysSelected: Bool {
        if case .always = selectedSchedule { return true }
        return false
    }
    
    private var isWorkHoursSelected: Bool {
        if case .dailyTimeRange(9, 0, 17, 0) = selectedSchedule { return true }
        return false
    }
    
    private var isWeekdaysSelected: Bool {
        if case .weekdays(let days) = selectedSchedule,
           days.count == 5 && days.contains(.monday) { return true }
        return false
    }
}

struct ScheduleOptionButton: View {
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        .frame(width: 20, height: 20)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.white.opacity(0.1) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


// MARK: - Supporting Views

struct BlockingRuleCard: View {
    let rule: AppBlockingRule
    @StateObject private var screenTimeManager = ScreenTimeManager()
    
    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(rule.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    DifficultyBadge(difficulty: rule.difficultyLevel)
                }
                
                if !rule.blockedApps.isEmpty {
                    Text("\(rule.blockedApps.count) apps blocked")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                HStack {
                    Text(scheduleText(for: rule.schedule))
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    DSButton(
                        "Apply",
                        style: .primary,
                        size: .small
                    ) {
                        Task {
                            // Apply the blocking rule
                            if !screenTimeManager.screenTimeSelection.applicationTokens.isEmpty {
                                await screenTimeManager.blockSelectedApps()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func scheduleText(for schedule: AppBlockingRule.BlockingSchedule) -> String {
        switch schedule {
        case .always:
            return "Always active"
        case .timeRange(let start, let end):
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Time range: \(formatter.string(from: start)) - \(formatter.string(from: end))"
        case .dailyTimeRange(let startHour, let startMinute, let endHour, let endMinute):
            return "Daily: \(String(format: "%02d:%02d", startHour, startMinute)) - \(String(format: "%02d:%02d", endHour, endMinute))"
        case .weekdays(let days):
            return "Weekdays: \(days.map { $0.shortName }.joined(separator: ", "))"
        case .custom(let days, _):
            let dayNames = days.map { $0.shortName }.joined(separator: ", ")
            return "Custom: \(dayNames)"
        }
    }
}

struct DifficultyBadge: View {
    let difficulty: AppBlockingRule.DifficultyLevel
    
    var body: some View {
        Text(difficulty.emoji + " " + difficulty.name)
            .font(.system(size: 12, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
    
    private var backgroundColor: Color {
        switch difficulty {
        case .gentle:
            return .green.opacity(0.8)
        case .moderate:
            return .orange.opacity(0.8)
        case .strict:
            return .red.opacity(0.8)
        case .nuclear:
            return .purple.opacity(0.8)
        }
    }
}
