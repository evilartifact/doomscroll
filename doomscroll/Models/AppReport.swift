import Foundation

struct AppReport: Identifiable, Codable {
    var id: String { bundleIdentifier }

    let bundleIdentifier: String
    let displayName: String
    let duration: TimeInterval
}

extension TimeInterval {
    func toScreenTimeString() -> String {
        let time = NSInteger(self)
        
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        return String(format: "%0.2d:%0.2d", hours, minutes)
    }
    
    func toFormattedScreenTime() -> String {
        return self.toScreenTimeString().replacingOccurrences(of: ":", with: "h")
    }
}
