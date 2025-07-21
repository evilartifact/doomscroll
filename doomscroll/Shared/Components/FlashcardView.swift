//
//  FlashcardView.swift
//  doomscroll
//
//  Created by Rabin on 7/6/25.
//

import SwiftUI

struct FlashcardView: View {
    let flashcard: Flashcard
    @State private var isFlipped = false
    @State private var dragOffset = CGSize.zero
    @State private var isBeingDragged = false
    @State private var currentIndex: Int = 0
    
    let onSwipeLeft: () -> Void
    let onSwipeRight: () -> Void
    
    var body: some View {
        // Compute rotation angle (0 or 180)
        let angle = isFlipped ? 180.0 : 0.0
        
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .frame(width: 320, height: 480)
                .shadow(radius: 6)
                .overlay(
                    Group {
                        if isFlipped {
                            cardBack
                                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        } else {
                            cardFront
                        }
                    }
                )
                .rotation3DEffect(
                    .degrees(angle),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
        .frame(width: 320, height: 480)
        .offset(dragOffset)
        .scaleEffect(1.0 - abs(dragOffset.width) / 2000)
        .rotationEffect(.degrees(Double(dragOffset.width / 30)))
        .opacity(1.0 - abs(dragOffset.width) / 600.0)
        .gesture(
            DragGesture()
                .onChanged { value in
                    isBeingDragged = true
                    dragOffset = value.translation
                }
                .onEnded { value in
                    isBeingDragged = false
                    let swipeThreshold: CGFloat = 120

                    if value.translation.width < -swipeThreshold {
                        // Swipe LEFT: previous card
                        withAnimation(.easeOut(duration: 0.4)) {
                            dragOffset = CGSize(width: -500, height: value.translation.height)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            onSwipeLeft() // This calls the left callback for previous
                            dragOffset = .zero
                        }
                    } else if value.translation.width > swipeThreshold {
                        // Swipe RIGHT: next card
                        withAnimation(.easeOut(duration: 0.4)) {
                            dragOffset = CGSize(width: 500, height: value.translation.height)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            onSwipeRight() // This calls the right callback for next
                            dragOffset = .zero
                        }
                    } else {
                        // Snap back to center
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            dragOffset = .zero
                        }
                    }
                }
        )
        .onTapGesture {
            if !isBeingDragged {
                withAnimation(.easeInOut(duration: 0.6)) {
                    isFlipped.toggle()
                }
            }
        }
    }

    private var cardFront: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
            .fill(Color.white)
            .shadow(
                color: .black.opacity(0.1),
                radius: 20,
                x: 0,
                y: 10
            )
            .shadow(
                color: .black.opacity(0.05),
                radius: 40,
                x: 0,
                y: 20
            )
            .overlay(
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Card type indicator
                    HStack {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: flashcard.type.icon)
                                .font(.caption)
                                .foregroundColor(flashcard.type.color)
                            
                            Text(flashcard.type.rawValue.capitalized)
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(flashcard.type.color)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(
                            Capsule()
                                .fill(flashcard.type.color.opacity(0.1))
                        )
                        
                        Spacer()
                        
                        // Flip indicator
                        Text("Tap to flip")
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(.gray.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    // Main content area
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // Emoji
                        Text(flashcard.emoji)
                            .font(.system(size: 64))
                        
                        // Front text
                        Text(flashcard.front)
                            .font(DesignSystem.Typography.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                    }
                    
                    Spacer()
                    
                    // Swipe hint
                    Text("← Swipe to navigate →")
                        .font(DesignSystem.Typography.caption2)
                        .foregroundColor(.gray.opacity(0.5))
                }
                .padding(DesignSystem.Spacing.xl)
            )
    }
    
    private var cardBack: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
            .fill(Color.white)
            .shadow(
                color: .black.opacity(0.1),
                radius: 20,
                x: 0,
                y: 10
            )
            .shadow(
                color: .black.opacity(0.05),
                radius: 40,
                x: 0,
                y: 20
            )
            .overlay(
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Card type indicator
                    HStack {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: flashcard.type.icon)
                                .font(.caption)
                                .foregroundColor(flashcard.type.color)
                            
                            Text("Answer")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(flashcard.type.color)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(
                            Capsule()
                                .fill(flashcard.type.color.opacity(0.1))
                        )
                        
                        Spacer()
                        
                        // Flip indicator
                        Text("Tap to flip")
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(.gray.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    // Main content area
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // Emoji (smaller on back)
                        Text(flashcard.emoji)
                            .font(.system(size: 40))
                        
                        // Back text
                        Text(flashcard.back)
                            .font(DesignSystem.Typography.body)
                            .fontWeight(.regular)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                    }
                    
                    Spacer()
                    
                    // Swipe hint
                    Text("← Swipe to navigate →")
                        .font(DesignSystem.Typography.caption2)
                        .foregroundColor(.gray.opacity(0.5))
                }
                .padding(DesignSystem.Spacing.xl)
            )
    }
}

struct FlashcardStackView: View {
    let flashcards: [Flashcard]
    @State private var currentIndex = 0
    @State private var completedCards: Set<UUID> = []
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Background cards (for depth effect)
            ForEach(Array(flashcards.enumerated().reversed()), id: \.element.id) { index, flashcard in
                if index >= currentIndex && index < currentIndex + 3 {
                    FlashcardView(
                        flashcard: flashcard,
                        onSwipeLeft: { nextCard() },
                        onSwipeRight: { previousCard() }
                    )
                    .scaleEffect(index == currentIndex ? 1.0 : 0.95 - CGFloat(index - currentIndex) * 0.05)
                    .offset(y: CGFloat(index - currentIndex) * 8)
                    .opacity(index == currentIndex ? 1.0 : 0.6 - CGFloat(index - currentIndex) * 0.2)
                    .allowsHitTesting(index == currentIndex)
                    .zIndex(Double(flashcards.count - index))
                }
            }
            
            // Show empty state if no flashcards or all completed
            if flashcards.isEmpty {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("No flashcards available")
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    
                    Text("This chapter doesn't have practice flashcards.")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .frame(width: 320, height: 480)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                        .fill(DesignSystem.Colors.cardBackground)
                        .shadow(
                            color: .black.opacity(0.1),
                            radius: 20,
                            x: 0,
                            y: 10
                        )
                )
                .padding(DesignSystem.Spacing.xl)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentIndex)
    }
    
    private func nextCard() {
        // Play swipe sound
        SoundManager.shared.playCardSwipeSound()
        
        if currentIndex < flashcards.count - 1 {
            completedCards.insert(flashcards[currentIndex].id)
            currentIndex += 1
        } else if currentIndex == flashcards.count - 1 {
            // Last card completed - automatically complete the chapter
            completedCards.insert(flashcards[currentIndex].id)
            currentIndex += 1
            
            // Small delay for the swipe animation to complete, then call onComplete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onComplete()
            }
        }
    }
    
    private func previousCard() {
        // Play swipe sound
        SoundManager.shared.playCardSwipeSound()
        
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }
    
    private func restart() {
        currentIndex = 0
        completedCards.removeAll()
    }
}

#Preview {
    FlashcardView(
        flashcard: Flashcard(
            front: "What triggers dopamine release?",
            back: "Unpredictable rewards - like notifications, likes, and new content",
            emoji: "🧠",
            type: .concept
        ),
        onSwipeLeft: {},
        onSwipeRight: {}
    )
    .padding()
    .background(DesignSystem.Colors.background)
} 
