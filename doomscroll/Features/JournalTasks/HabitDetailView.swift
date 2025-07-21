//
//  HabitDetailView.swift
//  doomscroll
//
//  Created by Rabin on 7/8/25.
//

import SwiftUI
#if canImport(Charts)
import Charts
#endif

struct HabitDetailView: View {
    let habit: Habit
    @StateObject private var habitManager = HabitManager.shared
    @StateObject private var levelManager = LevelManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTimeRange: TimeRange = .week
    @State private var showingResetConfirmation = false
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .year: return 365
            }
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                headerSection
                quickStatsSection
                progressChartSection
                milestonesSection
                recentActivitySection
                totalStatsSection
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(BackgroundView())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .alert("Reset Today's Progress", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetTodaysProgress()
            }
        } message: {
            Text("This will reset today's completion for '\(habit.title)'. This cannot be undone.")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.blue)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Reset Today", systemImage: "arrow.clockwise") {
                    showingResetConfirmation = true
                }
                .foregroundColor(.blue)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(habit.emoji)
                .font(.system(size: 35))
            
            Text(habit.title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Quick Stats Section
    private var quickStatsSection: some View {
        HStack(spacing: 12) {
            // Total Progress
            statCard(
                title: "Total Progress",
                value: "\(habit.totalProgress)",
                subtitle: habit.unit.rawValue,
                color: .blue
            )
            
            // Gems Earned
            statCard(
                title: "Gems Earned",
                value: "\(totalGemsEarned)",
                subtitle: "gems",
                color: .yellow
            )
            
            // Best Streak
            statCard(
                title: "Best Streak",
                value: "\(habit.bestStreak)",
                subtitle: "days",
                color: .orange
            )
        }
    }
    
    private func statCard(title: String, value: String, subtitle: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Progress Chart Section
    private var progressChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Progress Chart")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 180)
            }
            
            // Chart
            habitProgressChart
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Milestones Section
    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Milestones")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVStack(spacing: 12) {
                ForEach(milestones, id: \.target) { milestone in
                    milestoneRow(milestone)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func milestoneRow(_ milestone: Milestone) -> some View {
        HStack(spacing: 16) {
            // Milestone Image
            Image("milestone\(milestone.imageNumber)")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .opacity(milestone.isAchieved ? 1.0 : 0.3)
            
            // Milestone Info
            VStack(alignment: .leading, spacing: 4) {
                Text(milestone.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(milestone.isAchieved ? .white : .white.opacity(0.7))
                
                if milestone.isAchieved {
                    Text("Completed!")
                        .font(.caption)
                        .foregroundColor(habit.category.color)
                } else {
                    Text("\(milestone.target - habit.totalProgress) remaining")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            Spacer()
            
            // Progress or Checkmark
            if milestone.isAchieved {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(habit.category.color)
                    .font(.system(size: 20))
            } else {
                Text("\(Int((Double(habit.totalProgress) / Double(milestone.target)) * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(16)
        .background(milestoneBackground(milestone.isAchieved))
    }
    
    private func milestoneBackground(_ isAchieved: Bool) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isAchieved ? habit.category.color.opacity(0.1) : Color.white.opacity(0.02))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isAchieved ? habit.category.color.opacity(0.3) : Color.white.opacity(0.05), lineWidth: 1)
            )
    }
    
    // MARK: - Recent Activity Section
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVStack(spacing: 8) {
                ForEach(recentCompletions.prefix(10), id: \.self) { date in
                    HStack {
                        Circle()
                            .fill(habit.category.color)
                            .frame(width: 8, height: 8)
                        
                        Text(formatDate(date))
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text("+\(habit.gemsPerCompletion) gems")
                            .font(.caption)
                            .foregroundColor(.yellow.opacity(0.8))
                    }
                    .padding(.vertical, 4)
                }
                
                if recentCompletions.isEmpty {
                    Text("No recent activity")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Total Stats Section
    private var totalStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All-Time Statistics")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                statsRow("Total Completions", value: "\(habit.completedDates.count)")
                statsRow("Days Since Started", value: "\(daysSinceStarted)")
                statsRow("Completion Rate", value: "\(completionRate)%")
                statsRow("Average per Week", value: String(format: "%.1f", averagePerWeek))
                statsRow("Total Gems Earned", value: "\(totalGemsEarned)")
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func statsRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.vertical, 2)
    }
    
    // MARK: - Chart View
    private var habitProgressChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            #if canImport(Charts) && compiler(>=5.7)
            if #available(iOS 16.0, *) {
                progressChart
            } else {
                chartFallback
            }
            #else
            chartFallback
            #endif
            
            Text("Tracking \(habit.unit.rawValue) per completion")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
    }
    
    @available(iOS 16.0, *)
    private var progressChart: some View {
        #if canImport(Charts)
        return Chart(progressData) { dataPoint in
            BarMark(
                x: .value("Date", dataPoint.date, unit: .day),
                y: .value("Progress", dataPoint.progress)
            )
            .foregroundStyle(habit.category.color)
            .opacity(dataPoint.progress > 0 ? 1.0 : 0.3)
        }
        .frame(height: 200)
        #else
        return chartFallback
        #endif
    }
    
    private var chartFallback: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.3))
            Text("Progress visualization")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            
            // Simple progress indicators
            HStack(spacing: 8) {
                ForEach(progressData.suffix(7)) { dataPoint in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(dataPoint.progress > 0 ? habit.category.color : Color.white.opacity(0.1))
                            .frame(width: 20, height: max(CGFloat(dataPoint.progress) * 5, 4))
                        
                        Text(dayOfWeek(dataPoint.date))
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            .frame(height: 100)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
    
    private func dayOfWeek(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    // MARK: - Computed Properties
    private var totalGemsEarned: Int {
        habit.completedDates.count * habit.gemsPerCompletion
    }
    
    private var daysSinceStarted: Int {
        let calendar = Calendar.current
        let now = Date()
        let startDate = habit.completedDates.min() ?? now
        return calendar.dateComponents([.day], from: startDate, to: now).day ?? 0
    }
    
    private var completionRate: Int {
        let days = max(daysSinceStarted, 1)
        let expectedCompletions = habit.frequency.expectedCompletionsInDays(days)
        let actualCompletions = habit.completedDates.count
        return min(100, Int((Double(actualCompletions) / Double(max(expectedCompletions, 1))) * 100))
    }
    
    private var averagePerWeek: Double {
        let weeks = max(Double(daysSinceStarted) / 7.0, 1.0)
        return Double(habit.completedDates.count) / weeks
    }
    
    private var recentCompletions: [Date] {
        habit.completedDates.sorted(by: >)
    }
    
    private var progressData: [ProgressDataPoint] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -selectedTimeRange.days, to: endDate) ?? endDate
        
        var data: [ProgressDataPoint] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let progress = habit.completedDates.contains { calendar.isDate($0, inSameDayAs: currentDate) } ? habit.targetAmount : 0
            data.append(ProgressDataPoint(date: currentDate, progress: progress))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return data
    }
    
    private var milestones: [Milestone] {
        let targets: [Int]
        
        switch habit.unit {
        case .minutes:
            targets = [60, 180, 300, 600, 1200, 3000, 6000]
        case .pages:
            targets = [25, 50, 100, 250, 500, 1000, 2500]
        case .exercises:
            targets = [10, 25, 50, 100, 250, 500, 1000]
        case .times:
            targets = [7, 21, 50, 100, 200, 365, 730]
        case .hours:
            targets = [5, 20, 50, 100, 250, 500, 1000]
        case .words:
            targets = [1000, 5000, 10000, 25000, 50000, 100000, 250000]
        }
        
        return targets.enumerated().map { index, target in
            Milestone(
                target: target,
                title: "\(target) \(habit.unit.rawValue)",
                isAchieved: habit.totalProgress >= target,
                imageNumber: index + 1
            )
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func resetTodaysProgress() {
        let calendar = Calendar.current
        let today = Date()
        
        // Check if habit was completed today before resetting
        guard habit.isCompletedToday else { return }
        
        // Remove today's progress from total progress
        habit.totalProgress -= habit.targetAmount
        
        // Remove today's completion date
        habit.completedDates.removeAll { date in
            calendar.isDate(date, inSameDayAs: today)
        }
        
        // Update last completed date
        habit.lastCompletedDate = habit.completedDates.max()
        
        // Recalculate streak properly
        if let lastDate = habit.lastCompletedDate {
            // Find the streak leading up to the last completion
            habit.currentStreak = calculateStreakFromDate(lastDate)
        } else {
            habit.currentStreak = 0
        }
        
        // Subtract gems from level manager (reverse the gem addition)
        levelManager.removeGems(habit.gemsPerCompletion, reason: "Reset: \(habit.title)")
        
        // Force refresh both managers
        habitManager.objectWillChange.send()
        levelManager.objectWillChange.send()
        
        // Save changes
        habitManager.saveData()
        
        // Provide haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func calculateStreakFromDate(_ endDate: Date) -> Int {
        let calendar = Calendar.current
        let sortedDates = habit.completedDates.sorted(by: >)
        
        guard !sortedDates.isEmpty else { return 0 }
        
        var streak = 1
        var currentDate = endDate
        
        for i in 1..<sortedDates.count {
            let previousDate = sortedDates[i]
            let daysBetween = calendar.dateComponents([.day], from: previousDate, to: currentDate).day ?? 0
            
            if daysBetween == 1 || (habit.frequency == .weekdays && isValidWeekdayStreak(from: previousDate, to: currentDate)) {
                streak += 1
                currentDate = previousDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func isValidWeekdayStreak(from: Date, to: Date) -> Bool {
        let calendar = Calendar.current
        let fromWeekday = calendar.component(.weekday, from: from)
        let toWeekday = calendar.component(.weekday, from: to)
        
        // Valid weekday streak patterns
        if fromWeekday == 6 && toWeekday == 2 { // Friday to Monday
            return calendar.dateComponents([.day], from: from, to: to).day == 3
        }
        return calendar.dateComponents([.day], from: from, to: to).day == 1
    }
}

// MARK: - Supporting Types
struct ProgressDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let progress: Int
}

struct Milestone {
    let target: Int
    let title: String
    let isAchieved: Bool
    let imageNumber: Int
}

// MARK: - Extensions

extension HabitFrequency {
    func expectedCompletionsInDays(_ days: Int) -> Int {
        switch self {
        case .daily:
            return days
        case .weekdays:
            return (days * 5) / 7  // Approximate weekdays
        case .weekends:
            return (days * 2) / 7  // Approximate weekends
        case .weekly:
            return days / 7
        case .custom(let customDays):
            return (days * customDays) / 7
        }
    }
} 
