//
//  EducationView.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import SwiftUI

struct EducationView: View {
    @StateObject private var learningManager = LearningManager.shared
    @StateObject private var levelManager = LevelManager.shared
    
    // Use item-based presentation instead of boolean + separate state
    @State private var presentedChapter: LearningChapter?
    @State private var showingDoneForToday = false
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 0) {
                VStack(spacing: 12){
                    // Top stats header - stick to top
                    topStatsHeader
                    
                    // Progress card
                    progressCard
                }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.md)
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // Chapter path with callback
                        ChapterPathView(
                            chapters: learningManager.chapters,
                            onChapterSelected: { chapter in
                                // Check if chapter can be accessed today
                                if learningManager.canAccessChapter(chapter.id) {
                                    print("🔍 🎯 SELECTED CHAPTER DEBUG:")
                                    print("🔍   Chapter ID: \(chapter.id)")
                                    print("🔍   Chapter Title: \(chapter.title)")
                                    print("🔍   Chapter Number: \(chapter.chapter)")
                                    print("🔍   Flashcards: \(chapter.flashcards.count)")
                                    print("🔍   Quiz exists: \(chapter.quizQuestion != nil)")
                                    
                                    presentedChapter = chapter  // Single state mutation drives presentation
                                } else {
                                    print("🔍 Chapter \(chapter.title) cannot be accessed today")
                                    showingDoneForToday = true
                                }
                            }
                        )
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.top, 0)
                }
            }
        }
        .fullScreenCover(item: $presentedChapter) { chapter in
            ChapterDetailView(chapter: chapter)
                .onAppear {
                    print("🔍 Presenting ChapterDetailView for: \(chapter.title)")
                }
                .onDisappear {
                    print("🔍 ChapterDetailView disappeared, clearing presentedChapter")
                    presentedChapter = nil
                }
        }
        .sheet(isPresented: $showingDoneForToday) {
            DoneForTodaySheet(isPresented: $showingDoneForToday)
                .presentationDetents([.height(620)])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(0)
        }
    }
    
    private var topStatsHeader: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            // Gems
            HStack(spacing: 6) {
                Image("gem")
                    .resizable()
                    .frame(width: 30, height: 30)
                
                Text("\(levelManager.currentGems)")
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }
            
            Spacer()
            
            
            // Level image and number
            HStack(spacing: 8) {
                Image(levelManager.currentLevelInfo.imageName)
                    .resizable()
                    .frame(width: 30, height: 30)
                
                    Text("Lvl \(levelManager.currentLevel)")
                        .font(DesignSystem.Typography.headline)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
            }

            
            Spacer()
            
            
            // Streak
            HStack(spacing: 6) {
                Image("flame.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                
                Text("\(levelManager.currentStreak)")
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }
            
            }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
    
    private var progressCard: some View {
        // Get current active part color
        let currentActiveChapter = learningManager.chapters.first { !$0.isCompleted && $0.isUnlocked } ?? learningManager.chapters.first
        let currentPartColor = currentActiveChapter?.partColor ?? DesignSystem.Colors.primary
        
        return HStack(spacing: DesignSystem.Spacing.md) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Progress")
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("\(learningManager.completedChaptersCount) of \(learningManager.chapters.count) chapters completed")
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // Progress circle
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 8)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: learningManager.totalProgress)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: learningManager.totalProgress)
                
                Text("\(Int(learningManager.totalProgress * 100))%")
                    .font(DesignSystem.Typography.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .padding(DesignSystem.Spacing.md)
        .background(currentPartColor)
        .cornerRadius(DesignSystem.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .stroke(Color.white.opacity(0.03), lineWidth: 0.1)
                .mask(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .padding(.bottom, 24)
                )
        )
        .shadow(
            color: currentPartColor.opacity(0.8),
            radius: 0,
            x: 0,
            y: 6
        )
    }
}

#Preview {
    EducationView()
} 
