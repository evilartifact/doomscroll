//
//  CleanJournalDetailView.swift
//  doomscroll
//
//  Created by AI on 7/5/25.
//

import SwiftUI

struct CleanJournalDetailView: View {
    let entry: JournalEntry
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingDeleteAlert = false
    
    // Date formatters
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return formatter
    }()
    
    var body: some View {
        ZStack {
            BackgroundView()
            mainContent
        }
        .navigationBarHidden(true)
        .confirmationDialog("Journal Options", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                dataManager.deleteJournalEntry(entry)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
        .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.width > 50 && abs(value.translation.height) < 50 {
                        dismiss()
                    }
                }
        )
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            headerSection
            scrollableContent
        }
    }
    
    private var headerSection: some View {
        HStack {
            backButton
            Spacer()
            actionButtons
        }
        .padding(.horizontal)
        .padding(.top, 15)
    }
    
    private var backButton: some View {
        Button(action: { dismiss() }) {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.headline)
            }
            .foregroundColor(DesignSystem.Colors.primary)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            editButton
            deleteButton
        }
    }
    
    private var editButton: some View {
        DSNavigationLink(destination: CleanEditJournalView(entry: entry).environmentObject(dataManager)) {
            Text("Edit")
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.primary)
        }
    }
    
    private var deleteButton: some View {
        Button(action: { showingDeleteAlert = true }) {
            Image(systemName: "ellipsis")
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.primary)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
    
    private var scrollableContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                // Title
                titleSection
                
                // Date
                dateSection
                
                // Mood indicator | Tags scrollview (if either exists)
                if entry.mood != nil || !entry.tags.isEmpty {
                    moodAndTagsRow
                }
                
                // Content
                contentSection
                    .padding(.top, 20)
            }
            .padding()
        }
    }
    
    private var titleSection: some View {
        Text(entry.title)
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var dateSection: some View {
        Text(dateFormatter.string(from: entry.date))
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.6))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var moodAndTagsRow: some View {
        HStack(spacing: 16) {
            // Mood indicator (if exists)
            if let mood = entry.mood {
                moodIndicator(for: mood)
            }
            
            // Separator line (if both mood and tags exist)
            if entry.mood != nil && !entry.tags.isEmpty {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 28)
            }
            
            // Tags scrollview (if exists)
            if !entry.tags.isEmpty {
                tagsScrollView
            }
            
            Spacer()
        }
    }
    
    private func moodIndicator(for mood: JournalEntry.MoodLevel) -> some View {
        Text(mood.emoji)
            .font(.title2)
            .frame(width: 30)
    }
    
    private var tagsScrollView: some View {
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
    
    private var contentSection: some View {
        Group {
            if !entry.content.isEmpty {
                Text(entry.content)
                    .font(.body)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
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
}

#Preview {
    CleanJournalDetailView(entry: JournalEntry.example)
        .environmentObject(DataManager.shared)
} 
