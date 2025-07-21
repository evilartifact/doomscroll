//
//  QuickMoodEntryView.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import SwiftUI

struct QuickMoodEntryView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var isPresented: Bool
    
    @State private var selectedMood: MoodEntry.MoodLevel = .okay
    @State private var selectedEnergy: MoodEntry.EnergyLevel = .moderate
    @State private var selectedContext: MoodEntry.MoodContext = .general
    @State private var notes: String = ""
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Mood Selection
            moodSelectionSection
            
            // Energy Selection
            energySelectionSection
            
            // Context Selection
            contextSelectionSection
            
            // Notes
            notesSection
            
            Spacer()
            
            // Save Button
            DSButton("Save Mood Entry", style: .primary) {
                saveMoodEntry()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 22)
    }
    
    private var moodSelectionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("How are you feeling?")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(MoodEntry.MoodLevel.allCases, id: \.self) { mood in
                    Button(action: {
                        selectedMood = mood
                    }) {
                        VStack(spacing: DesignSystem.Spacing.xs) {
                            Text(mood.emoji)
                                .font(.title2)
                            
                            Text(mood.description)
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(
                                    selectedMood == mood ? 
                                    DesignSystem.Colors.textPrimary : 
                                    DesignSystem.Colors.textSecondary
                                )
                        }
                        .padding(DesignSystem.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                .fill(selectedMood == mood ? 
                                      DesignSystem.Colors.primary.opacity(0.2) : 
                                      Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                        .stroke(
                                            selectedMood == mood ? 
                                            DesignSystem.Colors.primary : 
                                            DesignSystem.Colors.cardBorder,
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var energySelectionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Energy Level")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(MoodEntry.EnergyLevel.allCases, id: \.self) { energy in
                    Button(action: {
                        selectedEnergy = energy
                    }) {
                        VStack(spacing: DesignSystem.Spacing.xs) {
                            Text(energy.emoji)
                                .font(.title3)
                            
                            Text(energy.description)
                                .font(DesignSystem.Typography.caption2)
                                .foregroundColor(
                                    selectedEnergy == energy ? 
                                    DesignSystem.Colors.textPrimary : 
                                    DesignSystem.Colors.textSecondary
                                )
                        }
                        .padding(DesignSystem.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                .fill(selectedEnergy == energy ? 
                                      DesignSystem.Colors.warning.opacity(0.2) : 
                                      Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                        .stroke(
                                            selectedEnergy == energy ? 
                                            DesignSystem.Colors.warning : 
                                            DesignSystem.Colors.cardBorder,
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var contextSelectionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Context")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(MoodEntry.MoodContext.allCases, id: \.self) { context in
                    Button(action: {
                        selectedContext = context
                    }) {
                        HStack {
                            Text(context.description)
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Spacer()
                            
                            if selectedContext == context {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(DesignSystem.Colors.success)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                            }
                        }
                        .padding(DesignSystem.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                .fill(DesignSystem.Colors.backgroundTertiary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                        .stroke(
                                            selectedContext == context ? 
                                            DesignSystem.Colors.success : 
                                            DesignSystem.Colors.cardBorder,
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Notes (Optional)")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            TextField("How are you feeling? What's on your mind?", text: $notes, axis: .vertical)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(DesignSystem.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .fill(DesignSystem.Colors.backgroundTertiary)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                .stroke(DesignSystem.Colors.cardBorder, lineWidth: 1)
                        )
                )
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .lineLimit(3...6)
        }
    }
    
    private func saveMoodEntry() {
        let entry = MoodEntry(
            date: Date(),
            mood: selectedMood,
            energy: selectedEnergy,
            context: selectedContext,
            notes: notes
        )
        
        dataManager.addMoodEntry(entry)
        isPresented = false
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var isPresented = true
        
        var body: some View {
            Text("Preview")
                .dsSheet(title: "Quick Mood Check", isPresented: $isPresented) {
                    QuickMoodEntryView(isPresented: $isPresented)
                }
                .environmentObject(DataManager.shared)
        }
    }
    
    return PreviewWrapper()
} 
