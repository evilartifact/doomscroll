//
//  CurvedPath.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import SwiftUI

struct ChapterPathView: View {
    let chapters: [LearningChapter]
    let onChapterSelected: (LearningChapter) -> Void
    @StateObject private var learningManager = LearningManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Render path items (chapters + dividers)
                ForEach(Array(getPathItems().enumerated()), id: \.offset) { index, item in
                    let position = calculatePosition(for: index, in: geometry.size)
                    
                    switch item {
                    case .chapter(let chapter):
                        let isUnlocked = chapter.isUnlocked
                        
                        ChapterButtonWithLabel(
                            chapter: chapter,
                            isUnlocked: isUnlocked,
                            action: isUnlocked ? {
                                onChapterSelected(chapter)
                            } : {
                                print("🔍 Chapter \(chapter.title) is locked")
                            }
                        )
                        .position(position)
                        
                    case .divider(let partNumber, let title):
                        PartDividerView(partNumber: partNumber, title: title)
                            .position(CGPoint(x: geometry.size.width / 2, y: position.y))
                    }
                }
            }
        }
        .frame(height: calculateTotalHeight())
    }
    
    private enum PathItem {
        case chapter(LearningChapter)
        case divider(partNumber: Int, title: String)
    }
    
    private func getPathItems() -> [PathItem] {
        var items: [PathItem] = []
        var currentPart = 0
        
        for chapter in chapters {
            if chapter.part != currentPart {
                currentPart = chapter.part
                let partTitle = getPartTitle(for: currentPart)
                items.append(.divider(partNumber: currentPart, title: partTitle))
            }
            items.append(.chapter(chapter))
        }
        
        return items
    }
    
    private func calculatePosition(for index: Int, in size: CGSize) -> CGPoint {
        let verticalAmplitude: CGFloat = 80
        let horizontalAmplitude: CGFloat = size.width * 0.15
        let centerX = size.width / 2

        let waveLength = 4 // Number of steps to center
        let pathItems = getPathItems()

        // Precompute equally spaced points along a sine curve using arc length
        let samples = 1000
        var arcLengths: [CGFloat] = [0]
        var prevPoint = CGPoint(x: 0, y: 0)
        var totalLength: CGFloat = 0

        // Sample the curve
        for i in 1...samples {
            let t = CGFloat(i) / CGFloat(samples)
            let theta = t * .pi
            let x = sin(theta)
            let y = t
            let point = CGPoint(x: x, y: y)
            let d = hypot(point.x - prevPoint.x, point.y - prevPoint.y)
            totalLength += d
            arcLengths.append(totalLength)
            prevPoint = point
        }

        // Now, for each path item, find the position on the curve with equally spaced arc length
        let step = totalLength / CGFloat(waveLength)
        let group = index / waveLength
        let posInWave = index % waveLength

        let desiredArcLength = CGFloat(posInWave) * step
        // Find closest sample to this arc length
        let i = arcLengths.enumerated().min(by: { abs($0.1 - desiredArcLength) < abs($1.1 - desiredArcLength) })!.0
        let t = CGFloat(i) / CGFloat(samples)

        // Alternate direction for each group
        let direction: CGFloat = (group % 2 == 0) ? 1 : -1

        // The x, y on the curve for this path item
        let xOffset = direction * sin(t * .pi) * horizontalAmplitude
        let yOffset = CGFloat(index) * verticalAmplitude + 60

        return CGPoint(x: centerX + xOffset, y: yOffset)
    }
    
    private func calculateTotalHeight() -> CGFloat {
        let verticalSpacing: CGFloat = 80
        let pathItems = getPathItems()
        return CGFloat(pathItems.count) * verticalSpacing + 120
    }
    
    private func getPartTitle(for part: Int) -> String {
        switch part {
        case 1: return "The Problem"
        case 2: return "Building Focus"
        case 3: return "Digital Wellness"
        case 4: return "Long-term Habits"
        case 5: return "Advanced Techniques"
        default: return "Part \(part)"
        }
    }
}

// Part divider component for separating different parts
struct PartDividerView: View {
    let partNumber: Int
    let title: String
    
    var body: some View {
        // Curved divider line
        HStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.3))
                .frame(height: 2)
                .frame(maxWidth: .infinity)
            
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.3))
                .padding(.vertical, 6)
            
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.3))
                .frame(height: 2)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
    }
    
    private var partColor: Color {
        switch partNumber {
        case 1: return DesignSystem.Colors.primary // Blue
        case 2: return .green
        case 3: return .purple
        case 4: return .orange
        case 5: return .red
        default: return DesignSystem.Colors.primary
        }
    }
}

#Preview {
    ScrollView {
        let chapterLoader = ChapterLoader()
        ChapterPathView(chapters: chapterLoader.chapters) { chapter in
            print("🔍 Preview: Chapter selected: \(chapter.title)")
        }
    }
    .background(BackgroundView())
}
