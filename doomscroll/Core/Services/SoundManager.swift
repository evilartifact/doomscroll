import Foundation
import AVFoundation
import AudioToolbox

@MainActor
class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playCompletionSound() {
        playSound(named: "completion", type: "mp3")
    }
    
    func playCardSwipeSound() {
        playSound(named: "swipe", type: "mp3")
    }
    
    func playButtonTapSound() {
        playSound(named: "tap", type: "mp3")
    }
    
    private func playSound(named soundName: String, type: String) {
        // For now, we'll use system sounds since we don't have custom audio files
        // This can be replaced with custom sounds later
        switch soundName {
        case "completion":
            playSystemSound(1322) // Duolingo-like completion sound
        case "swipe":
            playSystemSound(1104) // Subtle swipe sound
        case "tap":
            playSystemSound(1123) // Button tap sound
        default:
            break
        }
    }
    
    private func playSystemSound(_ soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }
    
    // Method to play custom audio files when available
    private func playCustomSound(named soundName: String, type: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: type) else {
            print("Could not find sound file: \(soundName).\(type)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }
} 