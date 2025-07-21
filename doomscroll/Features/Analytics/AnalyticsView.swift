//
//  AnalyticsView.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()
                
                ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Overview Stats
                    overviewSection
                    
                    // Placeholder for charts
                    chartsSection
                    
                    // Insights
                    insightsSection
                }
                .padding(DesignSystem.Spacing.md)
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Overview")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: DesignSystem.Spacing.md) {
                DSCard {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        HStack {
                            Image(systemName: "shield.fill")
                                .foregroundColor(DesignSystem.Colors.success)
                            Text("Urges Resisted")
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        
                        Text("\(urgesResistedCount)")
                            .font(DesignSystem.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                }
                
                DSCard {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        HStack {
                            Image(systemName: "percent")
                                .foregroundColor(DesignSystem.Colors.primary)
                            Text("Success Rate")
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        
                        Text("\(Int(successRate * 100))%")
                            .font(DesignSystem.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                }
                
                DSCard {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(DesignSystem.Colors.warning)
                            Text("Avg Mood")
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
                            Image(systemName: "calendar")
                                .foregroundColor(DesignSystem.Colors.primary)
                            Text("Total Entries")
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        
                        Text("\(totalEntries)")
                            .font(DesignSystem.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                }
            }
        }
    }
    
    private var chartsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Charts & Trends")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            DSCard {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.title)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Text("Advanced Analytics")
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text("Detailed charts and insights will be available in Phase 2")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 200)
            }
        }
    }
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Insights")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            ForEach(insights, id: \.title) { insight in
                DSCard {
                    HStack {
                        Image(systemName: insight.icon)
                            .foregroundColor(insight.color)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(insight.title)
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Text(insight.description)
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var urgesResistedCount: Int {
        return dataManager.urgeEntries.filter { $0.outcome.isPositive }.count
    }
    
    private var successRate: Double {
        guard !dataManager.urgeEntries.isEmpty else { return 0 }
        let positiveCount = dataManager.urgeEntries.filter { $0.outcome.isPositive }.count
        return Double(positiveCount) / Double(dataManager.urgeEntries.count)
    }
    
    private var averageMoodText: String {
        guard !dataManager.moodEntries.isEmpty else { return "No data" }
        let average = dataManager.moodEntries.reduce(0) { $0 + $1.mood.rawValue } / dataManager.moodEntries.count
        let mood = MoodEntry.MoodLevel(rawValue: average) ?? .okay
        return "\(mood.emoji) \(mood.description)"
    }
    
    private var totalEntries: Int {
        return dataManager.moodEntries.count + dataManager.urgeEntries.count
    }
    
    private var insights: [Insight] {
        var insights: [Insight] = []
        
        // Most common trigger
        if let mostCommonTrigger = getMostCommonTrigger() {
            insights.append(Insight(
                title: "Most Common Trigger",
                description: "\(mostCommonTrigger.emoji) \(mostCommonTrigger.description) is your most frequent urge trigger",
                icon: "exclamationmark.triangle.fill",
                color: DesignSystem.Colors.warning
            ))
        }
        
        // Success rate insight
        if successRate > 0.7 {
            insights.append(Insight(
                title: "Great Progress!",
                description: "You're successfully resisting \(Int(successRate * 100))% of your urges",
                icon: "star.fill",
                color: DesignSystem.Colors.success
            ))
        } else if successRate > 0.4 {
            insights.append(Insight(
                title: "Keep Going!",
                description: "You're making progress with a \(Int(successRate * 100))% success rate",
                icon: "arrow.up.circle.fill",
                color: DesignSystem.Colors.primary
            ))
        }
        
        // Mood insight
        if !dataManager.moodEntries.isEmpty {
            let recentMoods = dataManager.moodEntries.prefix(7)
            let averageRecent = recentMoods.reduce(0) { $0 + $1.mood.rawValue } / recentMoods.count
            
            if averageRecent >= 4 {
                insights.append(Insight(
                    title: "Positive Mood Trend",
                    description: "Your mood has been consistently good recently",
                    icon: "heart.fill",
                    color: DesignSystem.Colors.success
                ))
            }
        }
        
        return insights
    }
    
    private func getMostCommonTrigger() -> UrgeEntry.UrgeTrigger? {
        let triggers = dataManager.urgeEntries.map { $0.trigger }
        let triggerCounts = Dictionary(grouping: triggers, by: { $0 })
            .mapValues { $0.count }
        
        return triggerCounts.max(by: { $0.value < $1.value })?.key
    }
}

// MARK: - Insight Model
struct Insight {
    let title: String
    let description: String
    let icon: String
    let color: Color
}

#Preview {
    AnalyticsView()
        .environmentObject(DataManager.shared)
} 