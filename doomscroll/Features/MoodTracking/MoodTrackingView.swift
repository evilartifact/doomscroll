//
//  MoodTrackingView.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import SwiftUI

struct MoodTrackingView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showNewEntry = false
    @State private var selectedPeriod: TimePeriod = .thisWeek
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()
                
                ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Overview cards
                    overviewSection
                    
                    // Period selector
                    periodSelectorSection
                    
                    // Mood trend (placeholder)
                    moodTrendSection
                    
                    // Recent entries
                    recentEntriesSection
                }
                .padding(DesignSystem.Spacing.md)
                }
            }
            .navigationTitle("Mood Tracking")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    DSButton("Add Entry", style: .ghost, size: .small) {
                        showNewEntry = true
                    }
                }
            }
        }
        .dsSheet(title: "New Mood Entry", isPresented: $showNewEntry) {
            QuickMoodEntryView(isPresented: $showNewEntry)
        }
    }
    
    private var overviewSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: DesignSystem.Spacing.md) {
            DSCard {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(DesignSystem.Colors.primary)
                        Text("Average Mood")
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    Text(averageMoodText)
                        .font(DesignSystem.Typography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                }
            }
            
            DSCard {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                            .foregroundColor(DesignSystem.Colors.success)
                        Text("Entries This Week")
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    Text("\(entriesThisWeek)")
                        .font(DesignSystem.Typography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                }
            }
        }
    }
    
    private var periodSelectorSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("View Period")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach([TimePeriod.thisWeek, .lastWeek, .thisMonth, .lastMonth], id: \.self) { period in
                        Button(action: {
                            selectedPeriod = period
                        }) {
                            Text(periodName(period))
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(selectedPeriod == period ? DesignSystem.Colors.textPrimary : DesignSystem.Colors.textSecondary)
                                .padding(.horizontal, DesignSystem.Spacing.md)
                                .padding(.vertical, DesignSystem.Spacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                        .fill(selectedPeriod == period ? DesignSystem.Colors.primary.opacity(0.2) : Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                                .stroke(selectedPeriod == period ? DesignSystem.Colors.primary : DesignSystem.Colors.cardBorder, lineWidth: 1)
                                        )
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
            }
        }
    }
    
    private var moodTrendSection: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text("Mood Trend")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                // Placeholder for chart
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Text("Mood chart will be implemented in Phase 2")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 120)
            }
        }
    }
    
    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Recent Entries")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            if filteredEntries.isEmpty {
                DSCard {
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "heart.slash")
                            .font(.title2)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        
                        Text("No mood entries yet")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        
                        Text("Start tracking your mood to see patterns and insights")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                }
            } else {
                ForEach(filteredEntries) { entry in
                    moodEntryCard(entry)
                }
            }
        }
    }
    
    private func moodEntryCard(_ entry: MoodEntry) -> some View {
        DSCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(entry.mood.emoji)
                                .font(.title2)
                            
                            Text(entry.mood.description)
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Spacer()
                            
                            Text(timeAgo(from: entry.date))
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }
                        
                        HStack {
                            Text(entry.energy.emoji)
                                .font(.callout)
                            
                            Text("Energy: \(entry.energy.description)")
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                            
                            Spacer()
                            
                            Text(entry.context.description)
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }
                    }
                }
                
                if !entry.notes.isEmpty {
                    Text(entry.notes)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .padding(.top, DesignSystem.Spacing.xs)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var averageMoodText: String {
        let average = dataManager.getAverageMood(for: selectedPeriod)
        guard average > 0 else { return "No data" }
        
        let mood = MoodEntry.MoodLevel(rawValue: Int(average)) ?? .okay
        return "\(mood.emoji) \(mood.description)"
    }
    
    private var entriesThisWeek: Int {
        return dataManager.moodEntries.filter { entry in
            let weekRange = TimePeriod.thisWeek.dateRange
            return entry.date >= weekRange.start && entry.date <= weekRange.end
        }.count
    }
    
    private var filteredEntries: [MoodEntry] {
        let dateRange = selectedPeriod.dateRange
        return dataManager.moodEntries.filter { entry in
            entry.date >= dateRange.start && entry.date <= dateRange.end
        }
    }
    
    private func periodName(_ period: TimePeriod) -> String {
        switch period {
        case .thisWeek: return "This Week"
        case .lastWeek: return "Last Week"
        case .thisMonth: return "This Month"
        case .lastMonth: return "Last Month"
        default: return "Custom"
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// Make TimePeriod hashable for ForEach
extension TimePeriod: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .today: hasher.combine("today")
        case .yesterday: hasher.combine("yesterday")
        case .thisWeek: hasher.combine("thisWeek")
        case .lastWeek: hasher.combine("lastWeek")
        case .thisMonth: hasher.combine("thisMonth")
        case .lastMonth: hasher.combine("lastMonth")
        case .custom(let start, let end): 
            hasher.combine("custom")
            hasher.combine(start)
            hasher.combine(end)
        }
    }
    
    static func == (lhs: TimePeriod, rhs: TimePeriod) -> Bool {
        switch (lhs, rhs) {
        case (.today, .today), (.yesterday, .yesterday), (.thisWeek, .thisWeek), (.lastWeek, .lastWeek), (.thisMonth, .thisMonth), (.lastMonth, .lastMonth):
            return true
        case (.custom(let start1, let end1), .custom(let start2, let end2)):
            return start1 == start2 && end1 == end2
        default:
            return false
        }
    }
}

#Preview {
    MoodTrackingView()
        .environmentObject(DataManager.shared)
} 