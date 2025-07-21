//
//  CelebrationViews.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import SwiftUI
import AVFoundation

// Individual habit completion sheet
struct HabitCompletionSheet: View {
    let habit: Habit
    @Binding var isPresented: Bool
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        ZStack {
            // Background matching task color
            habit.category.color
                .ignoresSafeArea(.all)
            
            // Confetti
            ConfettiView()
            
            VStack(alignment: .leading, spacing: 16) {
                    Text("Great Job!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                        HStack(spacing: 6){
                            // Habit emoji
                            Text(habit.emoji)
                                .font(.system(size: 25))
                                .scaleEffect(1.1)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isPresented)
                            
                            Text(habit.title)
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                            
                            Spacer()
                            
                            HStack(spacing: 6) {
                                Image("gem")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                
                                Text("\(habit.gemsPerCompletion)")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                }
                
                // Close button
                DSButton("Continue", style: .white, size: .medium) {
                    isPresented = false
                }
            }
            .padding(20)
        }
        .onAppear {
            playCompletionSound()
        }
    }
    
    private func playCompletionSound() {
        guard let url = Bundle.main.url(forResource: "success", withExtension: "mp3") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }
}

// All tasks completed celebration sheet
struct AllTasksCompletedSheet: View {
    let completedHabit: Habit
    let totalGemsEarned: Int
    @Binding var isPresented: Bool
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        ZStack {
            // Background matching last task color
            completedHabit.category.color
                .ignoresSafeArea(.all)
            
            // Confetti
            ConfettiView()
            
            VStack(spacing: 16) {
                // Goblin celebration
                Image("celebrating")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
                    .scaleEffect(1.05)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isPresented)
                
                
                    Text("Well done!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("You've completed all your tasks for today!")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                    
                    
                    // Total gems for the day
                    HStack(spacing: 8) {
                        Image("gem")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)
                        
                        Text("\(totalGemsEarned) earned today")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                
                // Close button
                DSButton("Awesome!", style: .white, size: .medium) {
                    isPresented = false
                }
            }
            .padding(20)
        }
        .onAppear {
            playCelebrationSound()
        }
    }
    
    private func playCelebrationSound() {
        guard let url = Bundle.main.url(forResource: "celebration", withExtension: "mp3") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }
}

// Quiz correct answer celebration sheet
struct QuizCongratulationSheet: View {
    let gemsEarned: Int
    @Binding var isPresented: Bool
    let onCompletion: () -> Void
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        ZStack {
            // Background gradient
            Color.green
            .ignoresSafeArea(.all)
            
            // Confetti
            ConfettiView()
            
            VStack(spacing: 20) {
                // Goblin celebration
                Image("happy")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 250, height: 250)
                    .scaleEffect(1.05)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isPresented)
                
                Text("Correct! 🎉")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("You nailed it! That's some solid brain power right there.")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                
                // Gems earned
                HStack(spacing: 8) {
                    Image("gem")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22)
                    
                    Text("+\(gemsEarned) gems earned!")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                // Close button
                DSButton("Sweet!", style: .white, size: .medium) {
                    isPresented = false
                    onCompletion()
                }
            }
            .padding(20)
        }
        .onAppear {
            playSuccessSound()
        }
    }
    
    private func playSuccessSound() {
        guard let url = Bundle.main.url(forResource: "success", withExtension: "mp3") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }
}

// Chapter completion celebration sheet
struct ChapterCompletionSheet: View {
    let chapter: LearningChapter
    @Binding var isPresented: Bool
    let onDismiss: (() -> Void)?
    @State private var audioPlayer: AVAudioPlayer?
    
    init(chapter: LearningChapter, isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil) {
        self.chapter = chapter
        self._isPresented = isPresented
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        ZStack {
            // Background matching chapter part color
            chapter.partColor
                .ignoresSafeArea(.all)
            
            // Confetti
            ConfettiView()
            
            VStack(spacing: 20) {
                // Goblin celebration
                Image("happy")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 280, height: 280)
                    .scaleEffect(1.05)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isPresented)
                
                Text("Chapter Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("You finished \"\(chapter.title)\" like a boss!")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                
                // Gems earned
                HStack(spacing: 8) {
                    Image("gem")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                    
                    Text("+\(chapter.gemsReward) gems earned!")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                // Close button
                DSButton("Awesome!", style: .white, size: .medium) {
                    isPresented = false
                    onDismiss?()
                }
            }
            .padding(20)
        }
        .onAppear {
            playCelebrationSound()
        }
    }
    
    private func playCelebrationSound() {
        guard let url = Bundle.main.url(forResource: "celebration", withExtension: "mp3") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }
}

// Quiz wrong answer sheet
struct QuizErrorSheet: View {
    let correctAnswer: String
    let explanation: String
    @Binding var isPresented: Bool
    let onCompletion: () -> Void
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        ZStack {
            // Background gradient
            Color.red
            .ignoresSafeArea(.all)
            
            VStack(spacing: 20) {
                // Goblin disappointed
                Image("sad")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 220, height: 220)
                    .scaleEffect(1.05)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isPresented)
                
                Text("Not Quite Right!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Hey, no worries! Learning is all about trying and improving.")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                
                // Correct answer explanation
                VStack(spacing: 12) {
                    Text("Correct Answer:")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(correctAnswer)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                    
                    Text(explanation)
                        .font(.callout)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
                
                // Close button
                DSButton("Got It!", style: .white, size: .medium) {
                    isPresented = false
                    onCompletion()
                }
            }
            .padding(20)
        }
        .onAppear {
            playErrorSound()
        }
    }
    
    private func playErrorSound() {
        guard let url = Bundle.main.url(forResource: "error", withExtension: "mp3") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }
}

// Done for today sheet
struct DoneForTodaySheet: View {
    @Binding var isPresented: Bool
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        ZStack {
            // Background gradient  
            Color.orange
                .ignoresSafeArea(.all)
            
            // Confetti
            ConfettiView()
            
            VStack(spacing: 20) {
                // Goblin resting
                Image("sleep")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 260, height: 260)
                    .scaleEffect(1.05)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isPresented)
                
                Text("Done for Today! 🌙")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("You've already completed a chapter today. Come back tomorrow for more learning!")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                
                Text("Rest is part of the journey. Your brain needs time to process what you've learned.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                // Close button
                DSButton("Got It!", style: .white, size: .medium) {
                    isPresented = false
                }
            }
            .padding(20)
        }
        .onAppear {
            playRestSound()
        }
    }
    
    private func playRestSound() {
        guard let url = Bundle.main.url(forResource: "error", withExtension: "mp3") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }
} 
