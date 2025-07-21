//
//  CleanEditJournalView.swift
//  doomscroll
//
//  Created by AI on 7/5/25.
//

import SwiftUI

struct CleanEditJournalView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    let entry: JournalEntry
    @State private var title: String
    @State private var content: String
    @State private var selectedMood: JournalEntry.MoodLevel?
    @State private var tags: [String]
    @State private var newTag: String = ""
    @State private var showingTagPicker = false
    @State private var showingMoodPicker = false
    @State private var showingDiscardAlert = false
    @FocusState private var isTextFieldFocused: Bool
    @FocusState private var isTitleFieldFocused: Bool
    
    private let suggestedTags = ["gratitude", "reflection", "goals", "mindfulness", "work", "family", "health", "travel", "learning"]
    
    // Date formatter for display
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return formatter
    }()
    
    init(entry: JournalEntry) {
        self.entry = entry
        self._title = State(initialValue: entry.title)
        self._content = State(initialValue: entry.content)
        self._selectedMood = State(initialValue: entry.mood)
        self._tags = State(initialValue: entry.tags)
    }
    
    private var hasChanges: Bool {
        return title != entry.title ||
               content != entry.content ||
               selectedMood != entry.mood ||
               tags != entry.tags
    }
    
    var body: some View {
        ZStack {
            // Background
            BackgroundView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header section
                VStack(alignment: .leading, spacing: 4) {
                    // Back button
                    HStack {
                        Button(action: {
                            if hasChanges {
                                showingDiscardAlert = true
                            } else {
                                dismiss()
                            }
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .font(.title3)
                            }
                            .foregroundColor(DesignSystem.Colors.primary)
                        }
                        .padding(.bottom, 8)
                        
                        Spacer()
                    }
                    
                    // Title field
                    TextField("Memory title", text: $title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                        .focused($isTitleFieldFocused)
                    
                    // Date display
                    Text(dateFormatter.string(from: entry.date))
                        .font(.subheadline)
                        .foregroundColor(.primary.opacity(0.6))
                    
                    // Tags row if there are any
                    if !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    TagView(tag: tag) {
                                        tags.removeAll { $0 == tag }
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 15)
                
                // Content text editor
                TextEditor(text: $content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .padding([.horizontal, .top])
                    .focused($isTextFieldFocused)
                
                Spacer()
                
                // Bottom toolbar
                HStack {
                    // Mood button
                    Button(action: {
                        showingMoodPicker = true
                    }) {
                        Text(selectedMood?.emoji ?? "😐")
                            .font(.title3)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill((selectedMood?.color ?? Color.gray).opacity(0.2)))
                            .overlay(
                                Circle()
                                    .stroke(selectedMood?.color ?? Color.gray, lineWidth: 1.5)
                            )
                    }
                    
                    // Tags button
                    Button(action: {
                        showingTagPicker = true
                    }) {
                        Image(systemName: "tag")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                            .background(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1))
                    }
                    
                    Spacer()
                    
                    // Save button
                    DSButtonCompact(
                        "Save",
                        style: .danger,
                        size: .medium
                    ) {
                        saveChanges()
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 10)
            }
        }
        .navigationBarHidden(true)
        .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.width > 50 && abs(value.translation.height) < 50 {
                        if hasChanges {
                            showingDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    }
                }
        )
        .sheet(isPresented: $showingTagPicker) {
            TagPickerView(selectedTags: $tags)
                .presentationDetents([.height(400), .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingMoodPicker) {
            MoodPickerView(selectedMood: $selectedMood)
                .presentationDetents([.height(500), .large])
                .presentationDragIndicator(.visible)
        }
        .alert("Unsaved Changes", isPresented: $showingDiscardAlert) {
            Button("Discard", role: .destructive) {
                dismiss()
            }
            Button("Save") {
                saveChanges()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You have unsaved changes. Do you want to save them?")
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func saveChanges() {
        let updatedEntry = JournalEntry(
            id: entry.id,
            title: title.isEmpty ? "Untitled" : title,
            content: content,
            mood: selectedMood,
            tags: tags,
            date: entry.date
        )
        dataManager.updateJournalEntry(updatedEntry)
        dismiss()
    }
}

// MARK: - Supporting Views (reuse from AddJournalView)
// Note: Reusing TagView, TagPickerView, MoodPickerView, and FlowLayout from CleanAddJournalView

#Preview {
    CleanEditJournalView(entry: JournalEntry.example)
        .environmentObject(DataManager.shared)
} 
