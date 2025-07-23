//
//  ListItem.swift
//  doomscrollReportExtension
//
//  Created by Rabin on 7/22/25.
//

import SwiftUI
import UIKit

struct ListItem: View {
    private let app: AppReport
    @State private var appIcon: UIImage? = nil
    
    init(app: AppReport) {
        self.app = app
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // App Icon
            AppIconView(bundleIdentifier: app.id, appName: app.name)
                .frame(width: 50, height: 50)
                .cornerRadius(10)
                .shadow(radius: 2)
            
            // App Name and Category
            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("App Usage")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Duration
            VStack(alignment: .trailing) {
                Text(app.duration.toString().replacingOccurrences(of: ":", with: "h"))
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
    }
}

struct AppIconView: View {
    let bundleIdentifier: String
    let appName: String
    @State private var icon: UIImage? = nil
    
    var body: some View {
        Group {
            if let icon = icon {
                Image(uiImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                // Fallback icon with first letter of app name
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.2))
                    
                    Text(String(appName.prefix(1)))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .onAppear {
                    loadAppIcon()
                }
            }
        }
    }
    
    private func loadAppIcon() {
        if let url = URL(string: "file:///Applications/\(bundleIdentifier).app/AppIcon.png") {
            // This is a simplified approach - in a real app, you'd use a more robust method
            // to fetch app icons based on bundle ID, possibly using UIApplicationIcon API
            if let data = try? Data(contentsOf: url), 
               let image = UIImage(data: data) {
                self.icon = image
            }
        }
    }
}

struct List_Previews: PreviewProvider {
    static var previews: some View {
        ListItem(app: AppReport(id: "com.twitter.ios",
                                name: "Twitter",
                                duration: 3600))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
