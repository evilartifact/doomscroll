//
//  ChapterButton.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import SwiftUI

// Main button view that can be used standalone or inside DSNavigationLink
struct ChapterButton: View {
    let chapter: LearningChapter
    let isUnlocked: Bool
    let action: (() -> Void)?
    
    @State private var isPressed = false
    
    private let buttonSize: CGFloat = 60
    
    init(chapter: LearningChapter, isUnlocked: Bool, action: (() -> Void)? = nil) {
        self.chapter = chapter
        self.isUnlocked = isUnlocked
        self.action = action
    }
    
    var body: some View {
        ZStack {
            // Bottom shadow layer (darker version of main color) - stays fixed
            Ellipse()
                .fill(backgroundColor.opacity(0.7))
                .frame(width: buttonSize + 15, height: buttonSize)
                .offset(y: 6)
            
            // Main button surface - moves down when pressed
            Ellipse()
                .fill(backgroundColor)
                .frame(width: buttonSize + 15, height: buttonSize)
                .offset(y: isPressed ? 6 : 0)
                .overlay(
                    // Shine effect for completed buttons
                    Group {
                        if chapter.isCompleted {
                            Ellipse()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(stops: [
                                            .init(color: Color.white.opacity(0.4), location: 0.0),
                                            .init(color: Color.white.opacity(0.1), location: 0.3),
                                            .init(color: Color.clear, location: 1.0)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: buttonSize + 15, height: buttonSize)
                                .offset(y: isPressed ? 6 : 0)
                                .mask(
                                    Ellipse()
                                        .padding(.bottom, buttonSize * 0.5) // Shows on top half only
                                )
                        }
                    }
                )
            
            // Content - moves with the button
            Group {
                if isUnlocked {
                    if chapter.isCompleted {
                        // Completion checkmark
                        Image(systemName: chapter.systemIcon)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        // System icon with shadow opacity
                        Image(systemName: chapter.systemIcon)
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.black.opacity(0.3))
                    }
                } else {
                    // Lock icon
                    Image(systemName: chapter.systemIcon)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.black.opacity(0.4))
                }
            }
            .offset(y: isPressed ? 6 : 0)
            
            // Progress indicator (if chapter is started but not completed) - moves with button
            if isUnlocked && !chapter.isCompleted {
                Ellipse()
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: buttonSize + 30, height: buttonSize + 20)
                    .offset(y: 3)
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                    // Trigger action after animation if provided
                    if let action = action {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            action()
                        }
                    }
                }
        )
    }
    
    private var backgroundColor: Color {
        if !isUnlocked {
            return Color.gray
        }
        
        // Always use the part color, whether completed or not
        return chapter.partColor
    }
}

// Button with label for use in the curved path
struct ChapterButtonWithLabel: View {
    let chapter: LearningChapter
    let isUnlocked: Bool
    let action: (() -> Void)?
    
    init(chapter: LearningChapter, isUnlocked: Bool, action: (() -> Void)? = nil) {
        self.chapter = chapter
        self.isUnlocked = isUnlocked
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ChapterButton(
                chapter: chapter,
                isUnlocked: isUnlocked,
                action: action
            )
        }
        .frame(width: 100)
    }
}

#Preview {
    let chapterLoader = ChapterLoader()
    let chapters = chapterLoader.chapters
    VStack(spacing: 20) {
        if chapters.count > 0 {
            ChapterButtonWithLabel(
                chapter: chapters[0],
                isUnlocked: true,
                action: {}
            )
        }
        
        if chapters.count > 1 {
            ChapterButtonWithLabel(
                chapter: chapters[1],
                isUnlocked: false,
                action: {}
            )
        }
    }
    .padding()
    .background(BackgroundView())
} 
