//
//  QuickUrgeEntryView.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import SwiftUI

struct QuickUrgeEntryView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var isPresented: Bool
    
    @State private var intensity: Double = 5
    @State private var selectedTrigger: UrgeEntry.UrgeTrigger = .boredom
    @State private var selectedOutcome: UrgeEntry.UrgeOutcome = .resisted
    @State private var notes: String = ""
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Intensity Slider
            intensitySection
            
            // Trigger Selection
            triggerSelectionSection
            
            // Outcome Selection
            outcomeSelectionSection
            
            // Notes
            notesSection
            
            Spacer()
            
            // Save Button
            DSButton("Save Urge Entry", style: .primary) {
                saveUrgeEntry()
            }
        }
    }
    
    private var intensitySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Urge Intensity")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                Text("\(Int(intensity))/10")
                    .font(DesignSystem.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(intensityColor)
            }
            
            Slider(value: $intensity, in: 1...10, step: 1)
                .accentColor(intensityColor)
            
            HStack {
                Text("Mild")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Spacer()
                
                Text("Overwhelming")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
    }
    
    private var triggerSelectionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("What triggered this urge?")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: DesignSystem.Spacing.sm) {
                ForEach(UrgeEntry.UrgeTrigger.allCases, id: \.self) { trigger in
                    Button(action: {
                        selectedTrigger = trigger
                    }) {
                        VStack(spacing: DesignSystem.Spacing.xs) {
                            Text(trigger.emoji)
                                .font(.title3)
                            
                            Text(trigger.description)
                                .font(DesignSystem.Typography.caption2)
                                .foregroundColor(
                                    selectedTrigger == trigger ? 
                                    DesignSystem.Colors.textPrimary : 
                                    DesignSystem.Colors.textSecondary
                                )
                                .multilineTextAlignment(.center)
                        }
                        .padding(DesignSystem.Spacing.sm)
                        .frame(minHeight: 60)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                .fill(selectedTrigger == trigger ? 
                                      DesignSystem.Colors.warning.opacity(0.2) : 
                                      Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                        .stroke(
                                            selectedTrigger == trigger ? 
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
        }
    }
    
    private var outcomeSelectionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("What happened?")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(UrgeEntry.UrgeOutcome.allCases, id: \.self) { outcome in
                    Button(action: {
                        selectedOutcome = outcome
                    }) {
                        HStack {
                            Text(outcome.emoji)
                                .font(.title3)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(outcome.description)
                                    .font(DesignSystem.Typography.body)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text(outcomeSubtitle(for: outcome))
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }
                            
                            Spacer()
                            
                            if selectedOutcome == outcome {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(outcome.isPositive ? DesignSystem.Colors.success : DesignSystem.Colors.danger)
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
                                            selectedOutcome == outcome ? 
                                            (outcome.isPositive ? DesignSystem.Colors.success : DesignSystem.Colors.danger) : 
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
            
            TextField("What were you thinking or feeling? What helped?", text: $notes, axis: .vertical)
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
    
    private var intensityColor: Color {
        switch Int(intensity) {
        case 1...3: return DesignSystem.Colors.success
        case 4...6: return DesignSystem.Colors.warning
        case 7...10: return DesignSystem.Colors.danger
        default: return DesignSystem.Colors.primary
        }
    }
    
    private func outcomeSubtitle(for outcome: UrgeEntry.UrgeOutcome) -> String {
        switch outcome {
        case .resisted: return "Successfully fought off the urge"
        case .gavein: return "Ended up scrolling"
        case .redirected: return "Did something else instead"
        case .delayed: return "Put it off for later"
        }
    }
    
    private func saveUrgeEntry() {
        let entry = UrgeEntry(
            date: Date(),
            intensity: Int(intensity),
            trigger: selectedTrigger,
            duration: nil, // Can be added later if needed
            outcome: selectedOutcome,
            notes: notes
        )
        
        dataManager.addUrgeEntry(entry)
        isPresented = false
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var isPresented = true
        
        var body: some View {
            Text("Preview")
                .dsSheet(title: "Log Urge", isPresented: $isPresented) {
                    QuickUrgeEntryView(isPresented: $isPresented)
                }
                .environmentObject(DataManager.shared)
        }
    }
    
    return PreviewWrapper()
} 