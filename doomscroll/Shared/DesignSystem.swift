//
//  DesignSystem.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import SwiftUI

struct DesignSystem {
    // MARK: - Colors
    struct Colors {
        static let background = Color(red: 0.05, green: 0.05, blue: 0.08)
        static let backgroundSecondary = Color(red: 0.08, green: 0.08, blue: 0.12)
        static let backgroundTertiary = Color(red: 0.12, green: 0.12, blue: 0.16)
        
        static let primary = Color.blue
        static let primaryDark = Color(red: 0.3, green: 0.5, blue: 0.9)
        
        static let success = Color(red: 0.2, green: 0.8, blue: 0.4)
        static let warning = Color(red: 1.0, green: 0.6, blue: 0.2)
        static let danger = Color(red: 1.0, green: 0.3, blue: 0.3)
        
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.7)
        static let textTertiary = Color.white.opacity(0.5)
        
        static let cardBackground = Color(red: 0.1, green: 0.1, blue: 0.15)
        static let cardBorder = Color.white.opacity(0.1)
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title = Font.title.weight(.semibold)
        static let title2 = Font.title2.weight(.semibold)
        static let headline = Font.headline.weight(.medium)
        static let body = Font.body
        static let callout = Font.callout
        static let caption = Font.caption
        static let caption2 = Font.caption2
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let card = Shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        static let button = Shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
} 


// Helper Shape for only bottom corners rounded
struct RoundedCornersShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}


extension Color {
    /// Returns a darker version of this color by the given percentage (0.0 - 1.0)
    func darker(by percentage: CGFloat = 0.2) -> Color {
        // Convert Color to UIColor
        let uiColor = UIColor(self)
        var hue: CGFloat = 0, sat: CGFloat = 0, bri: CGFloat = 0, alpha: CGFloat = 0
        if uiColor.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha) {
            let newBrightness = max(bri - percentage, 0)
            return Color(hue: Double(hue), saturation: Double(sat), brightness: Double(newBrightness), opacity: Double(alpha))
        } else {
            // If conversion fails (e.g. system color), just return self
            return self
        }
    }
}
