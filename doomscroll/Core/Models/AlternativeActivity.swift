//
//  AlternativeActivity.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import Foundation

struct AlternativeActivity: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let category: ActivityCategory
    let duration: ActivityDuration
    let difficulty: ActivityDifficulty
    let location: ActivityLocation
    let emoji: String
    let benefits: [String]
    
    init(title: String, description: String, category: ActivityCategory, duration: ActivityDuration, difficulty: ActivityDifficulty, location: ActivityLocation, emoji: String, benefits: [String]) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.category = category
        self.duration = duration
        self.difficulty = difficulty
        self.location = location
        self.emoji = emoji
        self.benefits = benefits
    }
    
    enum ActivityCategory: String, CaseIterable, Codable {
        case physical = "physical"
        case creative = "creative"
        case social = "social"
        case mindful = "mindful"
        case productive = "productive"
        case learning = "learning"
        
        var name: String {
            switch self {
            case .physical: return "Physical"
            case .creative: return "Creative"
            case .social: return "Social"
            case .mindful: return "Mindful"
            case .productive: return "Productive"
            case .learning: return "Learning"
            }
        }
        
        var emoji: String {
            switch self {
            case .physical: return "🏃‍♂️"
            case .creative: return "🎨"
            case .social: return "👥"
            case .mindful: return "🧘‍♀️"
            case .productive: return "✅"
            case .learning: return "📚"
            }
        }
    }
    
    enum ActivityDuration: String, CaseIterable, Codable {
        case quick = "quick" // 1-5 minutes
        case short = "short" // 5-15 minutes
        case medium = "medium" // 15-30 minutes
        case long = "long" // 30+ minutes
        
        var name: String {
            switch self {
            case .quick: return "1-5 min"
            case .short: return "5-15 min"
            case .medium: return "15-30 min"
            case .long: return "30+ min"
            }
        }
        
        var minutes: ClosedRange<Int> {
            switch self {
            case .quick: return 1...5
            case .short: return 5...15
            case .medium: return 15...30
            case .long: return 30...120
            }
        }
    }
    
    enum ActivityDifficulty: String, CaseIterable, Codable {
        case easy = "easy"
        case moderate = "moderate"
        case challenging = "challenging"
        
        var name: String {
            switch self {
            case .easy: return "Easy"
            case .moderate: return "Moderate"
            case .challenging: return "Challenging"
            }
        }
        
        var emoji: String {
            switch self {
            case .easy: return "😌"
            case .moderate: return "💪"
            case .challenging: return "🔥"
            }
        }
    }
    
    enum ActivityLocation: String, CaseIterable, Codable {
        case anywhere = "anywhere"
        case indoor = "indoor"
        case outdoor = "outdoor"
        case home = "home"
        case work = "work"
        
        var name: String {
            switch self {
            case .anywhere: return "Anywhere"
            case .indoor: return "Indoor"
            case .outdoor: return "Outdoor"
            case .home: return "At Home"
            case .work: return "At Work"
            }
        }
    }
    
    static let activities: [AlternativeActivity] = [
        // Quick Physical Activities
        AlternativeActivity(
            title: "Deep Breathing",
            description: "Take 5 deep breaths, inhaling for 4 counts and exhaling for 6 counts",
            category: .mindful,
            duration: .quick,
            difficulty: .easy,
            location: .anywhere,
            emoji: "🫁",
            benefits: ["Reduces stress", "Improves focus", "Calms nervous system"]
        ),
        
        AlternativeActivity(
            title: "Desk Stretches",
            description: "Stretch your neck, shoulders, and back while sitting",
            category: .physical,
            duration: .quick,
            difficulty: .easy,
            location: .work,
            emoji: "🤸‍♀️",
            benefits: ["Relieves tension", "Improves posture", "Increases energy"]
        ),
        
        AlternativeActivity(
            title: "10 Jumping Jacks",
            description: "Get your heart rate up with a quick burst of movement",
            category: .physical,
            duration: .quick,
            difficulty: .easy,
            location: .anywhere,
            emoji: "🏃‍♂️",
            benefits: ["Boosts energy", "Improves circulation", "Releases endorphins"]
        ),
        
        AlternativeActivity(
            title: "Text a Friend",
            description: "Send a thoughtful message to someone you care about",
            category: .social,
            duration: .quick,
            difficulty: .easy,
            location: .anywhere,
            emoji: "💬",
            benefits: ["Strengthens relationships", "Spreads positivity", "Creates connection"]
        ),
        
        AlternativeActivity(
            title: "Write 3 Gratitudes",
            description: "Quickly jot down three things you're grateful for today",
            category: .mindful,
            duration: .quick,
            difficulty: .easy,
            location: .anywhere,
            emoji: "🙏",
            benefits: ["Improves mood", "Shifts perspective", "Increases happiness"]
        ),
        
        // Short Activities
        AlternativeActivity(
            title: "5-Minute Walk",
            description: "Take a short walk around your home, office, or neighborhood",
            category: .physical,
            duration: .short,
            difficulty: .easy,
            location: .anywhere,
            emoji: "🚶‍♂️",
            benefits: ["Clears mind", "Improves circulation", "Reduces stress"]
        ),
        
        AlternativeActivity(
            title: "Quick Sketch",
            description: "Draw whatever you see around you or doodle freely",
            category: .creative,
            duration: .short,
            difficulty: .easy,
            location: .anywhere,
            emoji: "✏️",
            benefits: ["Boosts creativity", "Improves focus", "Relaxes mind"]
        ),
        
        AlternativeActivity(
            title: "Tidy Up Space",
            description: "Organize your desk, room, or immediate surroundings",
            category: .productive,
            duration: .short,
            difficulty: .easy,
            location: .anywhere,
            emoji: "🧹",
            benefits: ["Reduces stress", "Improves focus", "Sense of accomplishment"]
        ),
        
        AlternativeActivity(
            title: "Listen to a Song",
            description: "Play your favorite uplifting song and really listen to it",
            category: .creative,
            duration: .short,
            difficulty: .easy,
            location: .anywhere,
            emoji: "🎵",
            benefits: ["Improves mood", "Reduces stress", "Boosts energy"]
        ),
        
        AlternativeActivity(
            title: "Mindful Observation",
            description: "Look around and notice 5 things you can see, 4 you can hear, 3 you can touch",
            category: .mindful,
            duration: .short,
            difficulty: .easy,
            location: .anywhere,
            emoji: "👁️",
            benefits: ["Grounds you in present", "Reduces anxiety", "Improves awareness"]
        ),
        
        AlternativeActivity(
            title: "Read Article",
            description: "Read an interesting article on a topic you're curious about",
            category: .learning,
            duration: .short,
            difficulty: .easy,
            location: .anywhere,
            emoji: "📰",
            benefits: ["Expands knowledge", "Improves focus", "Satisfies curiosity"]
        ),
        
        // Medium Activities
        AlternativeActivity(
            title: "Call Someone",
            description: "Have a real conversation with a friend or family member",
            category: .social,
            duration: .medium,
            difficulty: .easy,
            location: .anywhere,
            emoji: "📞",
            benefits: ["Deepens relationships", "Improves mood", "Provides support"]
        ),
        
        AlternativeActivity(
            title: "Yoga Session",
            description: "Follow a short yoga routine or stretch sequence",
            category: .physical,
            duration: .medium,
            difficulty: .moderate,
            location: .home,
            emoji: "🧘‍♀️",
            benefits: ["Reduces stress", "Improves flexibility", "Enhances mindfulness"]
        ),
        
        AlternativeActivity(
            title: "Journal Writing",
            description: "Write about your thoughts, feelings, or experiences",
            category: .creative,
            duration: .medium,
            difficulty: .easy,
            location: .anywhere,
            emoji: "📝",
            benefits: ["Processes emotions", "Improves self-awareness", "Reduces stress"]
        ),
        
        AlternativeActivity(
            title: "Learn Something New",
            description: "Watch an educational video or practice a skill",
            category: .learning,
            duration: .medium,
            difficulty: .moderate,
            location: .anywhere,
            emoji: "🎓",
            benefits: ["Expands knowledge", "Builds skills", "Boosts confidence"]
        ),
        
        AlternativeActivity(
            title: "Meal Preparation",
            description: "Prepare a healthy snack or plan your next meal",
            category: .productive,
            duration: .medium,
            difficulty: .easy,
            location: .home,
            emoji: "🍎",
            benefits: ["Improves nutrition", "Saves time later", "Mindful activity"]
        ),
        
        // Long Activities
        AlternativeActivity(
            title: "Exercise Workout",
            description: "Do a full workout routine or go for a longer run",
            category: .physical,
            duration: .long,
            difficulty: .challenging,
            location: .anywhere,
            emoji: "💪",
            benefits: ["Improves fitness", "Releases endorphins", "Builds discipline"]
        ),
        
        AlternativeActivity(
            title: "Creative Project",
            description: "Work on a painting, writing, music, or craft project",
            category: .creative,
            duration: .long,
            difficulty: .moderate,
            location: .home,
            emoji: "🎨",
            benefits: ["Develops skills", "Provides fulfillment", "Expresses creativity"]
        ),
        
        AlternativeActivity(
            title: "Read a Book",
            description: "Dive into a good book and lose yourself in the story",
            category: .learning,
            duration: .long,
            difficulty: .easy,
            location: .anywhere,
            emoji: "📚",
            benefits: ["Expands knowledge", "Improves focus", "Reduces stress"]
        ),
        
        AlternativeActivity(
            title: "Social Activity",
            description: "Meet up with friends or engage in a group activity",
            category: .social,
            duration: .long,
            difficulty: .easy,
            location: .outdoor,
            emoji: "👥",
            benefits: ["Builds relationships", "Creates memories", "Improves mood"]
        ),
        
        AlternativeActivity(
            title: "Nature Time",
            description: "Spend time outdoors, hiking, gardening, or just sitting in nature",
            category: .mindful,
            duration: .long,
            difficulty: .easy,
            location: .outdoor,
            emoji: "🌳",
            benefits: ["Reduces stress", "Improves mood", "Connects with nature"]
        )
    ]
    
    static func suggestActivity(
        for duration: ActivityDuration,
        category: ActivityCategory? = nil,
        location: ActivityLocation? = nil,
        difficulty: ActivityDifficulty? = nil
    ) -> AlternativeActivity? {
        var filteredActivities = activities.filter { $0.duration == duration }
        
        if let category = category {
            filteredActivities = filteredActivities.filter { $0.category == category }
        }
        
        if let location = location {
            filteredActivities = filteredActivities.filter { $0.location == location || $0.location == .anywhere }
        }
        
        if let difficulty = difficulty {
            filteredActivities = filteredActivities.filter { $0.difficulty == difficulty }
        }
        
        return filteredActivities.randomElement()
    }
    
    static func getRandomActivity() -> AlternativeActivity {
        return activities.randomElement()!
    }
} 