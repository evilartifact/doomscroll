//
//  CleanAddJournalView.swift
//  doomscroll
//
//  Created by AI on 7/5/25.
//

import SwiftUI

struct CleanAddJournalView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedMood: JournalEntry.MoodLevel? = nil
    @State private var tags: [String] = []
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
    
    private var hasChanges: Bool {
        return !title.isEmpty ||
               !content.isEmpty ||
               !tags.isEmpty ||
               selectedMood != nil
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
                    Text(dateFormatter.string(from: Date()))
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
                    .placeholder(when: content.isEmpty) {
                        Text("Write a few words about this memory")
                            .font(.body)
                            .foregroundColor(.primary.opacity(0.6))
                            .padding([.horizontal, .top])
                    }
                
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
                        saveJournal()
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
                saveJournal()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You have unsaved changes. Do you want to save them?")
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTitleFieldFocused = true
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func saveJournal() {
        let entry = JournalEntry(
            date: Date(),
            title: title.isEmpty ? "Untitled" : title,
            content: content,
            mood: selectedMood,
            tags: tags
        )
        dataManager.addJournalEntry(entry)
        dismiss()
    }
}

// MARK: - Supporting Views

struct TagView: View {
    let tag: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.caption)
                .foregroundColor(.primary)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.primary.opacity(0.7))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(Color.primary.opacity(0.1)))
    }
}

struct TagPickerView: View {
    @Binding var selectedTags: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var newTag = ""
    
    private let suggestedTags = ["gratitude", "reflection", "goals", "mindfulness", "work", "family", "health", "travel", "learning", "workout", "reading", "food"]
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        // Suggested tags
                        FlowLayout(spacing: 8) {
                            ForEach(suggestedTags, id: \.self) { tag in
                                Button(action: {
                                    toggleTag(tag)
                                }) {
                                    Text(tag)
                                        .font(.subheadline)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(selectedTags.contains(tag) ? DesignSystem.Colors.primary : Color.gray.opacity(0.2))
                                        )
                                        .foregroundColor(selectedTags.contains(tag) ? .white : .primary)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding()
                }
                
                // Custom tag input
                HStack {
                    TextField("Add custom tag", text: $newTag)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Add") {
                        if !newTag.isEmpty && !selectedTags.contains(newTag) {
                            selectedTags.append(newTag)
                            newTag = ""
                        }
                    }
                    .disabled(newTag.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.removeAll { $0 == tag }
        } else {
            selectedTags.append(tag)
        }
    }
}

struct MoodPickerView: View {
    @Binding var selectedMood: JournalEntry.MoodLevel?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text("How are you feeling?")
                .font(.headline)
                .padding(.top)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(JournalEntry.MoodLevel.allCases, id: \.self) { mood in
                    Button(action: {
                        selectedMood = mood
                        dismiss()
                    }) {
                        HStack(spacing: 10) {
                            Text(mood.emoji)
                                .font(.system(size: 22))
                            
                            Text(mood.description)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)
                        .background(
                            Capsule()
                                .fill(selectedMood == mood ? mood.color.opacity(0.2) : Color.primary.opacity(0.05))
                                .overlay(
                                    Capsule()
                                        .stroke(selectedMood == mood ? mood.color : Color.clear, lineWidth: 1.5)
                                )
                        )
                        .foregroundColor(selectedMood == mood ? mood.color : .primary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(height: 400)
    }
}

// Custom flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: CGSize(width: proposal.width ?? 0, height: .infinity),
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: CGSize(width: bounds.width, height: .infinity),
            subviews: subviews,
            spacing: spacing
        )
        
        for (index, pos) in result.positions.enumerated() {
            let subview = subviews[index]
            let size = result.sizes[index]
            let point = CGPoint(x: pos.x + bounds.minX, y: pos.y + bounds.minY)
            subview.place(at: point, proposal: ProposedViewSize(size))
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        var sizes: [CGSize] = []
        
        init(in size: CGSize, subviews: Subviews, spacing: CGFloat) {
            var currentPosition = CGPoint.zero
            var maxHeight: CGFloat = 0
            var row: (width: CGFloat, maxHeight: CGFloat) = (0, 0)
            
            for view in subviews {
                let viewDimension = view.sizeThatFits(ProposedViewSize(width: size.width, height: nil))
                
                if currentPosition.x + viewDimension.width > size.width && currentPosition.x > 0 {
                    currentPosition.x = 0
                    currentPosition.y += row.maxHeight + spacing
                    row = (0, 0)
                }
                
                positions.append(currentPosition)
                sizes.append(viewDimension)
                
                currentPosition.x += viewDimension.width + spacing
                row.width += viewDimension.width + spacing
                row.maxHeight = max(row.maxHeight, viewDimension.height)
                
                self.size.width = max(self.size.width, currentPosition.x)
                maxHeight = max(maxHeight, currentPosition.y + viewDimension.height)
            }
            
            self.size.height = maxHeight
        }
    }
}

// Placeholder extension
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .topLeading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            self
            
            placeholder()
                .opacity(shouldShow ? 0.6 : 0)
                .allowsHitTesting(false)
        }
    }
}

// Hide keyboard extension
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    CleanAddJournalView()
        .environmentObject(DataManager.shared)
} 
