//
//  ChapterDetailView.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import SwiftUI
import AVFoundation

struct ChapterDetailView: View {
    let chapter: LearningChapter
    @StateObject private var learningManager = LearningManager.shared
    @StateObject private var levelManager = LevelManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentTab: ChapterTab = .read
    @State private var currentSection: ChapterSection = .content
    @State private var currentFlashcardIndex = 0
    @State private var selectedAnswer: String? = nil
    @State private var hasAnsweredQuiz = false
    @State private var allowSwipeGestures = false
    @State private var showingChapterCompletion = false
    @State private var quizResult: QuizResult? = nil  // Single source of truth for quiz results
    
    enum QuizResult: Identifiable {
        case correct, incorrect
        var id: Int {
            switch self {
            case .correct: return 0
            case .incorrect: return 1
            }
        }
    }
    
    enum ChapterTab: CaseIterable {
        case read, flashcards, quiz
        
        var title: String {
            switch self {
            case .read: return "Read"
            case .flashcards: return "Flashcards"
            case .quiz: return "Quiz"
            }
        }
    }
    
    enum ChapterSection: CaseIterable {
        case content, keyPoints, actionItems
        
        var title: String {
            switch self {
            case .content: return "Content"
            case .keyPoints: return "Key Points"
            case .actionItems: return "Action Items"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            // Tab Content with ZStack for manual control
            ZStack {
                if currentTab == .read {
                    readTabView
                        .transition(.move(edge: .leading))
                }
                
                if currentTab == .flashcards {
                    flashcardsTabView
                        .transition(.move(edge: .trailing))
                }
                
                if currentTab == .quiz {
                    quizTabView
                        .transition(.move(edge: .trailing))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: currentTab)
            .gesture(
                // Only allow swipe gestures if chapter is completed
                chapter.isCompleted ? 
                DragGesture()
                    .onEnded { value in
                        let threshold: CGFloat = 100
                        if value.translation.width > threshold {
                            // Swipe right - go to previous tab
                            switch currentTab {
                            case .flashcards: currentTab = .read
                            case .quiz: currentTab = .flashcards
                            default: break
                            }
                        } else if value.translation.width < -threshold {
                            // Swipe left - go to next tab
                            switch currentTab {
                            case .read: currentTab = .flashcards
                            case .flashcards: if chapter.quizQuestion != nil { currentTab = .quiz }
                            default: break
                            }
                        }
                    } : nil
            )
        }
        .background(BackgroundView())
        .navigationBarHidden(true)
        .onAppear {
            allowSwipeGestures = chapter.isCompleted
        }
        .sheet(item: $quizResult) { result in
            switch result {
            case .correct:
                QuizCongratulationSheet(
                    gemsEarned: 5, // 5 gems for correct quiz answer
                    isPresented: Binding(
                        get: { quizResult != nil },
                        set: { if !$0 { quizResult = nil } }
                    )
                ) {
                    // Complete chapter automatically after quiz
                    completeChapter()
                }
                .presentationDetents([.height(550)]) // Correct answer sheet height
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(0)
            case .incorrect:
                QuizErrorSheet(
                    correctAnswer: chapter.quizQuestion?.correctAnswer ?? "",
                    explanation: chapter.quizQuestion?.explanation ?? "",
                    isPresented: Binding(
                        get: { quizResult != nil },
                        set: { if !$0 { quizResult = nil } }
                    )
                ) {
                    // Complete chapter automatically even after wrong answer
                    completeChapter()
                }
                .presentationDetents([.height(700)]) // Incorrect answer sheet height
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(0)
            }
        }
        .sheet(isPresented: $showingChapterCompletion) {
            ChapterCompletionSheet(
                chapter: chapter, 
                isPresented: $showingChapterCompletion,
                onDismiss: {
                    // Dismiss the fullscreen cover when chapter completion is dismissed
                    dismiss()
                }
            )
            .presentationDetents([.height(600)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(0)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            // Tab indicators
            HStack(spacing: 8) {
                ForEach(ChapterTab.allCases, id: \.self) { tab in
                    Circle()
                        .fill(currentTab == tab ? Color.white : Color.white.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            
            Spacer()
            
            HStack(spacing: 6) {
                Image("gem")
                    .resizable()
                    .frame(width: 20, height: 20)
                Text("\(chapter.gemsReward)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
    
    // MARK: - Read Tab
    private var readTabView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                // Chapter info card
                chapterInfoCard
                
                // Segmented control
                segmentedControl
                
                // Current section content
                currentSectionContent
                
                // Practice Flashcards Button (only show if chapter not completed)
                if !chapter.isCompleted && !chapter.flashcards.isEmpty {
                    DSButton("Practice Flashcards", style: .primary, size: .medium) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentTab = .flashcards
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                }
                
                Spacer(minLength: 50)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    // MARK: - Flashcards Tab (ZStack of flashcards)
    private var flashcardsTabView: some View {
        VStack(spacing: 24) {
            // Progress indicator
            HStack {
                Text("\(currentFlashcardIndex + 1) of \(chapter.flashcards.count)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Button("Back to Read") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentTab = .read
                    }
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Progress bar
            ProgressView(value: Double(currentFlashcardIndex + 1), total: Double(chapter.flashcards.count))
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .padding(.horizontal, 20)
            
            Spacer()
            
            // ZStack of flashcards - stacked with depth effect
            if !chapter.flashcards.isEmpty {
                ZStack {
                    ForEach(Array(chapter.flashcards.enumerated().reversed()), id: \.element.id) { index, flashcard in
                        if index >= currentFlashcardIndex && index < currentFlashcardIndex + 3 {
                            FlashcardView(
                                flashcard: flashcard,
                                onSwipeLeft: {
                                    // Swipe left = previous
                                    if currentFlashcardIndex > 0 {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            currentFlashcardIndex -= 1
                                        }
                                    }
                                },
                                onSwipeRight: {
                                    // Swipe right = next
                                    if currentFlashcardIndex < chapter.flashcards.count - 1 {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            currentFlashcardIndex += 1
                                        }
                                    }
                                }
                            )
                            .scaleEffect(index == currentFlashcardIndex ? 1.0 : 0.95 - CGFloat(index - currentFlashcardIndex) * 0.05)
                            .offset(y: CGFloat(index - currentFlashcardIndex) * 8)
                            .opacity(index == currentFlashcardIndex ? 1.0 : 0.6 - CGFloat(index - currentFlashcardIndex) * 0.2)
                            .allowsHitTesting(index == currentFlashcardIndex)
                            .zIndex(Double(chapter.flashcards.count - index))
                        }
                    }
                }
                .frame(height: 480)
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            // Show Take Quiz button only on last flashcard and if chapter not completed
            if currentFlashcardIndex == chapter.flashcards.count - 1 && chapter.quizQuestion != nil && !chapter.isCompleted {
                DSButton("Take Quiz", style: .primary, size: .medium) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentTab = .quiz
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
    }
    
    // MARK: - Quiz Tab
    private var quizTabView: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                Image("reading")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 260, height: 260)
                    .scaleEffect(1.05)
                    .padding(.top, 100)
                
                Text("Chapter Quiz")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .padding(.horizontal, 20)
                
                // Quiz content
                if let quiz = chapter.quizQuestion {
                    VStack(spacing: 20) {
                        // Question
                        Text(quiz.question)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        // Answer options or results for completed chapter
                        if chapter.isCompleted {
                            // Show correct answer for completed chapters
                            VStack(spacing: 16) {
                                // Correct answer (always show as green)
                                DSButton(quiz.correctAnswer, style: .success, size: .medium) {
                                    // No action for completed chapters
                                }
                                
                                // Wrong answer (always show as gray/disabled)
                                DSButton(quiz.wrongAnswer, style: .secondary, size: .medium) {
                                    // No action for completed chapters  
                                }
                                
                                // Show explanation
                                VStack(spacing: 12) {
                                    Text("Explanation")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(DesignSystem.Colors.textPrimary)
                                    
                                    Text(quiz.explanation)
                                        .font(.body)
                                        .foregroundColor(DesignSystem.Colors.textSecondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 20)
                                }
                                .padding(.top, 20)
                            }
                        } else {
                            // Interactive quiz for non-completed chapters
                            VStack(spacing: 16) {
                                // Create randomized order for answers
                                let answers = [(quiz.correctAnswer, true), (quiz.wrongAnswer, false)].shuffled()
                                
                                ForEach(Array(answers.enumerated()), id: \.offset) { index, answer in
                                    Button(action: {
                                        handleQuizAnswer(answer.0, isCorrect: answer.1)
                                    }) {
                                        Text(answer.0)
                                            .font(.body)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(nil)
                                            .padding(.vertical, 16)
                                            .padding(.horizontal, 20)
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .foregroundColor(Color.white.opacity(0.1))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                                    )
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                } else {
                    Text("No quiz available for this chapter")
                        .font(.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 100)
            }
        }
    }
    

    
    // MARK: - Chapter Info Card
    private var chapterInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(chapter.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(chapter.description)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                if chapter.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
            
            // Chapter Image
            Image(chapter.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: UIScreen.main.bounds.height * 0.3)
                .clipped()
                .cornerRadius(16)
        }
    }
    
    // MARK: - Segmented Control
    private var segmentedControl: some View {
        HStack(spacing: 0) {
            ForEach(ChapterSection.allCases, id: \.self) { section in
                Button(action: { currentSection = section }) {
                    Text(section.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(currentSection == section ? .black : .white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            currentSection == section ? 
                            Color.white : Color.clear
                        )
                }
            }
        }
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Current Section Content
    private var currentSectionContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            switch currentSection {
            case .content:
                contentSection
            case .keyPoints:
                keyPointsSection
            case .actionItems:
                actionItemsSection
            }
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 35) {
            ForEach(parseContent(chapter.content), id: \.self) { element in
                switch element {
                case .text(let content):
                    Text(parseTextWithBold(content))
                        .font(.body)
                        .foregroundColor(.white)
                        .lineSpacing(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                
                case .header(let title):
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
    
    private var keyPointsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(chapter.keyPoints.indices, id: \.self) { index in
                let point = chapter.keyPoints[index]
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.blue)
                    
                    Text(point)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .lineSpacing(4)
                    
                    Spacer()
                }
            }
        }
    }
    
    private var actionItemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(chapter.actionItems.indices, id: \.self) { index in
                let item = chapter.actionItems[index]
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.green)
                    
                    Text(item)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .lineSpacing(4)
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Content Parsing
    enum ContentElement: Hashable {
        case text(String)
        case header(String)
    }
    
    private func parseContent(_ content: String) -> [ContentElement] {
        var elements: [ContentElement] = []
        let paragraphs = content.components(separatedBy: "\n\n")
        
        for paragraph in paragraphs {
            let trimmed = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                if trimmed.hasPrefix("**") && trimmed.hasSuffix("**") {
                    // Header
                    let title = String(trimmed.dropFirst(2).dropLast(2))
                    elements.append(.header(title))
                } else {
                    // Regular text
                    elements.append(.text(trimmed))
                }
            }
        }
        
        return elements
    }
    
    private func parseTextWithBold(_ text: String) -> AttributedString {
        var result = AttributedString(text)
        
        // Find all **text** patterns and make them bold
        let pattern = #"\*\*(.*?)\*\*"#
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let nsString = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
        
        // Process matches in reverse order to maintain string indices
        for match in matches.reversed() {
            let matchRange = Range(match.range, in: text)!
            let contentRange = Range(match.range(at: 1), in: text)!
            let content = String(text[contentRange])
            
            if let attributedRange = Range(matchRange, in: result) {
                result.replaceSubrange(attributedRange, with: AttributedString(content))
                if let newRange = result.range(of: content) {
                    result[newRange].font = .body.bold()
                }
            }
        }
        
        return result
    }
    
    // MARK: - Actions
    private func handleQuizAnswer(_ answer: String, isCorrect: Bool) {
        selectedAnswer = answer
        
        // Double-check correctness by comparing with actual quiz data
        let actuallyCorrect = answer == chapter.quizQuestion?.correctAnswer
        print("🎯 Quiz Answer Debug:")
        print("🎯   Selected: \(answer)")
        print("🎯   Correct Answer: \(chapter.quizQuestion?.correctAnswer ?? "nil")")
        print("🎯   Is Correct: \(actuallyCorrect)")
        
        if actuallyCorrect {
            playSound(named: "success")
            // Award 5 gems for correct quiz answers
            levelManager.addGems(5, reason: "Correct quiz answer")
            print("💎 Awarded 5 gems for correct quiz answer")
            quizResult = .correct
        } else {
            playSound(named: "error")
            print("❌ Wrong answer, no gems awarded")
            quizResult = .incorrect
        }
        
        hasAnsweredQuiz = true
    }
    
    private func completeChapter() {
        learningManager.completeChapter(chapter.id)
        showingChapterCompletion = true
    }
    
    private func playSound(named soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("Could not find sound file: \(soundName).mp3")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }
} 
