import Foundation
import os.log

struct AppReport: Identifiable, Codable {
    var id: String
    var name: String
    var duration: TimeInterval
    
    var formattedDuration: String {
        return duration.toScreenTimeString()
    }
}
