//
//  JournalTasksView.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import SwiftUI

struct JournalTasksView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var habitManager = HabitManager.shared
    @State private var selectedDate = Date()
    @State private var showingCalendar = false
    @State private var showingHabitCompletion = false
    @State private var showingAllTasksCompleted = false
    @State private var completedHabit: Habit?
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Content based on selected date
                    ScrollView {
                        VStack(spacing: 30) {
                            // Tasks section
                            tasksSection
                            
                            
                            // Journals section
                            journalsSection
                            
                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
              
            }
        }
        .sheet(isPresented: $showingCalendar) {
            CalendarSheetView(selectedDate: $selectedDate, isPresented: $showingCalendar)
                .presentationDetents([.height(needsExtraButton ? 500 : 450)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingHabitCompletion) {
            if let habit = completedHabit {
                HabitCompletionSheet(habit: habit, isPresented: $showingHabitCompletion)
                    .presentationDetents([.height(180)])
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(0)
            } else {
                // Fallback view
                VStack {
                    Text("Error loading habit data")
                        .foregroundColor(.white)
                    DSButtonCompact("Close", style: .white, size: .small) {
                        showingHabitCompletion = false
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.red)
            }
        }
        .sheet(isPresented: $showingAllTasksCompleted) {
            if let habit = completedHabit {
                AllTasksCompletedSheet(
                    completedHabit: habit,
                    totalGemsEarned: todaysGemsEarned,
                    isPresented: $showingAllTasksCompleted
                )
                .presentationDetents([.height(550)])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(0)
            } else {
                // Fallback view
                VStack {
                    Text("Error loading habit data")
                        .foregroundColor(.white)
                    DSButtonCompact("Close", style: .white, size: .small) {
                        showingAllTasksCompleted = false
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.red)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func completeHabit(_ habit: Habit) {
        // Complete the habit first
        habitManager.completeHabit(habit)
        
        // Store the completed habit for the sheets
        completedHabit = habit
        
        // Small delay to ensure state is updated before showing sheets
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Check if this was the last habit for today
            let todayHabits = habitManager.todaysHabits
            let remainingHabits = todayHabits.filter { !$0.isCompletedToday }
            
            if remainingHabits.isEmpty && todayHabits.count > 0 {
                // All tasks completed - show celebration sheet
                showingAllTasksCompleted = true
            } else {
                // Individual task completed - show basic completion sheet
                showingHabitCompletion = true
            }
        }
    }
    
    private var todaysGemsEarned: Int {
        habitManager.todaysHabits
            .filter { $0.isCompletedToday }
            .reduce(0) { $0 + $1.gemsPerCompletion }
    }
    
    // Dynamically determine height based on whether we need an extra button
    private var needsExtraButton: Bool {
        !Calendar.current.isDateInToday(selectedDate)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Vault")
                    .font(DesignSystem.Typography.title)
                    .foregroundColor(.white)
                
                Text(selectedDate, formatter: dateSubtitleFormatter)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Calendar icon button
            Button(action: {
                showingCalendar = true
            }) {
                Image(systemName: "calendar")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.white.opacity(0.1)))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 16)
    }
    
    // MARK: - Journals Section
    private var journalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 4) {
                    Text("Journal Entries")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    let entriesCount = journalEntriesForDate(selectedDate).count
                    Text("(\(entriesCount) \(entriesCount == 1 ? "entry" : "entries"))")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                DSNavigationLink(destination: CleanAddJournalView().environmentObject(dataManager)) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.trailing, 20)
            }
            
            let entries = journalEntriesForDate(selectedDate)
            if entries.isEmpty {
                emptyJournalState
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(entries) { entry in
                        ModernJournalCard(entry: entry)
                    }
                }
            }
        }
    }
    
    // MARK: - Mood Indicator
    private func moodIndicator(for mood: JournalEntry.MoodLevel) -> some View {
        VStack(spacing: 4) {
            Text(mood.emoji)
                .font(.title2)
        }
        .frame(width: 30)
    }
    
    // MARK: - Modern Journal Card
    private func ModernJournalCard(entry: JournalEntry) -> some View {
        DSNavigationLink(destination: CleanJournalDetailView(entry: entry).environmentObject(dataManager)) {
            VStack(alignment: .leading, spacing: 12) {
                    HStack{
                        // Mood indicator - larger and more prominent
                        if let mood = entry.mood {
                            moodIndicator(for: mood)
                        }
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3)) // or your color
                            .frame(width: 1, height: 28)   // or any height you need

                        // Tags section with improved styling
                        if !entry.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(entry.tags, id: \.self) { tag in
                                        HStack(spacing: 4) {
                                            Text(getTagEmoji(for: tag))
                                                .font(.caption2)
                                            Text(tag)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(DesignSystem.Colors.primary.opacity(0.2))
                                        )
                                        .foregroundColor(DesignSystem.Colors.primary)
                                    }
                                }
                                .padding(.leading, 1)
                            }
                        }
                        
                    }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    if !entry.content.isEmpty {
                        Text(entry.content)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(3)
                    }
                }

                
                // Time stamp
                HStack {
                    Spacer()
                                         Text(entry.date, formatter: timeFormatter)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
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
    
    // MARK: - Empty Journal State
    private var emptyJournalState: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.3))
            
            VStack(spacing: 8) {
                Text("No entries for this day")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("Tap the + button to add your first journal entry")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 120) // Match regular journal card height
        .padding(.vertical, 16) // Match regular journal card padding
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Tasks Section
    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                    Text("Today's Tasks")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                
                Spacer()
                
                
                let todayHabits = habitManager.todaysHabits
                let completedCount = todayHabits.filter { $0.isCompletedToday }.count
                Text("\(completedCount)/\(todayHabits.count) done")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            let habits = habitManager.todaysHabits
            if habits.isEmpty {
                emptyTaskState
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(habits) { habit in
                        DSNavigationLink(destination: HabitDetailView(habit: habit)) {
                            HabitCard(habit: habit)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Habit Card
    private func HabitCard(habit: Habit) -> some View {
        HStack(spacing: 16) {
            // Completion circle with better visual feedback
            Button(action: {
                if !habit.isCompletedToday {
                    completeHabit(habit)
                }
            }) {
                ZStack {
                    Circle()
                        .stroke(habit.isCompletedToday ? DesignSystem.Colors.success : Color.white.opacity(0.3), lineWidth: 2.5)
                        .frame(width: 24, height: 24)
                    
                    if habit.isCompletedToday {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(DesignSystem.Colors.success)
                    } else {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .scaleEffect(habit.isCompletedToday ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: habit.isCompletedToday)
            .disabled(habit.isCompletedToday)
            
            VStack(alignment: .leading, spacing: 6) {
                                 HStack(spacing: 8) {
                         Text(habit.emoji)
                             .font(.system(size: 16))
                         Text(habit.title)
                             .font(.system(size: 16, weight: .medium))
                             .foregroundColor(habit.isCompletedToday ? .white.opacity(0.6) : .white)
                             .strikethrough(habit.isCompletedToday)
                     }
                
                // Category, frequency and streak display
                HStack(spacing: 12) {
                    // Category chip
                        Text(habit.category.name)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))

                    // Frequency indicator
                    Text(habit.frequency.description)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                        )
                    
                    // Streak indicator
                    if habit.currentStreak > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "flame.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                            Text("\(habit.currentStreak)")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Gem reward
            HStack(spacing: 4) {
                Image("gem")
                    .resizable()
                    .frame(width: 18, height: 18)
                Text("\(habit.gemsPerCompletion)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(DesignSystem.Colors.warning)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(habit.category.color.opacity(habit.isCompletedToday ? 0.99 : 0.1))
        )
        .opacity(habit.isCompletedToday ? 0.7 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: habit.isCompletedToday)
    }
    
    // MARK: - Empty Habits State
    private var emptyTaskState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checklist")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.3))
            
            VStack(spacing: 8) {
                Text("No habits for today")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("Rest day! Focus on journaling about your progress")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Helper Methods
    private func journalEntriesForDate(_ date: Date) -> [JournalEntry] {
        let calendar = Calendar.current
                 return dataManager.journalEntries.filter { entry in
             calendar.isDate(entry.date, inSameDayAs: date)
         }.sorted { $0.date > $1.date }
    }
    

    
    private func getTagEmoji(for tag: String) -> String {
        let tagEmojiMap: [String: String] = [
            "gratitude": "🙏",
            "reflection": "🤔",
            "goals": "🎯",
            "mindfulness": "🧘",
            "work": "💼",
            "family": "👨‍👩‍👧‍👦",
            "health": "🏃",
            "travel": "✈️",
            "learning": "📚"
        ]
        return tagEmojiMap[tag.lowercased()] ?? "🏷️"
    }
    
    // MARK: - Formatters
    private let dateSubtitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()
    
    private let dayMonthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

// MARK: - Calendar Sheet View
struct CalendarSheetView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    @Environment(\.colorScheme) private var colorScheme
    private let calendar = Calendar.current
    
    // Dynamically determine height based on whether we need an extra button
    private var needsExtraButton: Bool {
        !calendar.isDateInToday(selectedDate)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Calendar grid
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding(.horizontal)
                .padding(.top, 16)
                .accentColor(DesignSystem.Colors.primary)
                .onChange(of: selectedDate) { _ in
                    // Provide feedback when date changes
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
            
            // Jump to Date button
            DSButton(
                "Jump to \(formattedButtonDate(from: selectedDate))",
                style: .primary,
                size: .medium
            ) {
                isPresented = false
            }
            .padding(.horizontal)
            
            // Go to Today button (when not on today)
            if !calendar.isDateInToday(selectedDate) {
                DSButton(
                    "Go to Today",
                    style: .danger,
                    size: .medium
                ) {
                    selectedDate = calendar.startOfDay(for: Date())
                    isPresented = false
                }
                .padding(.horizontal)
            }
            
            // Add bottom padding
            Spacer()
                .frame(height: 16)
        }
        .background(Color(UIColor.systemBackground))
    }
    
    private func formattedButtonDate(from date: Date) -> String {
        if calendar.isDateInToday(date) {
            return "Today"
        } else if isTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
    
    private func isTomorrow(_ date: Date) -> Bool {
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())) {
            return calendar.isDate(date, inSameDayAs: tomorrow)
        }
        return false
    }
}

#Preview {
    JournalTasksView()
} 
