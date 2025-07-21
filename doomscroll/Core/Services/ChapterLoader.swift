//
//  ChapterLoader.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import Foundation

class ChapterLoader: ObservableObject {
    @Published var chapters: [LearningChapter] = []
    @Published var isLoading = true
    @Published var error: String?
    
    init() {
        loadChapters()
    }
    
    func loadChapters() {
        print("🔍 📖 LOADING CHAPTERS FROM JSON...")
        isLoading = true
        error = nil
        
        guard let url = Bundle.main.url(forResource: "chapters", withExtension: "json") else {
            print("🔍 ❌ Could not find chapters.json file")
            error = "Could not find chapters.json file"
            isLoading = false
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            print("🔍 ✅ Successfully loaded JSON data, size: \(data.count) bytes")
            
            let decoder = JSONDecoder()
            let chaptersResponse = try decoder.decode(ChaptersResponse.self, from: data)
            
            print("🔍 ✅ Successfully decoded \(chaptersResponse.chapters.count) chapters")
            
            DispatchQueue.main.async {
                self.chapters = chaptersResponse.chapters.map { $0.toLearningChapter() }
                self.isLoading = false
                
                print("🔍 📖 CHAPTERS LOADED SUCCESSFULLY:")
                for (index, chapter) in self.chapters.enumerated() {
                    print("  Chapter \(index + 1): \(chapter.title)")
                    print("    Flashcards: \(chapter.flashcards.count)")
                    print("    Quiz: \(chapter.quizQuestion != nil ? "✅" : "❌")")
                }
            }
        } catch {
            print("🔍 ❌ Error loading/parsing chapters: \(error)")
            DispatchQueue.main.async {
                self.error = "Error loading chapters: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
} 