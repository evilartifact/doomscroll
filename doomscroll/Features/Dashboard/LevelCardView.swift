//
//  LevelCardView.swift
//  doomscroll
//
//  Created by Rabin on 7/10/25.
//


import SwiftUI
import FamilyControls
import DeviceActivity

// MARK: - Level Card View
struct LevelCardView: View {
    @Binding var isPresented: Bool
    @StateObject private var levelManager = LevelManager.shared
    @State private var renderedImage: UIImage?
    @State private var isGeneratingImage = false
    @State private var shareURL: URL?
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            
            Text("Your Level card")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            // Main Level Card (same as in DashboardView)
            mainLevelCard
            
            // Share Button
            if let shareURL = shareURL {
                ShareLink(item: shareURL, preview: SharePreview("Level Card")) {
                    Label("Share Level Card", systemImage: "square.and.arrow.up")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.7))
                                    .offset(y: 6)
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue)
                            }
                        )
                        .padding(.horizontal, 12)
                }
            } else {
                Button(action: {
                    generateImage()
                }) {
                    HStack {
                        if isGeneratingImage {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.white)
                        }
                        Text(isGeneratingImage ? "Generating..." : "Prepare Share")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.7))
                            .offset(y: 6)
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                    }
                )
                .padding(.horizontal, 12)
                .disabled(isGeneratingImage)
            }
        }
        .padding(.vertical, 20)
        .onAppear {
            generateImage()
        }
    }
    
    private var mainLevelCard: some View {
        ZStack(alignment: .bottom) {
            // Full mesh gradient background
            MeshGradientView(
                colors: levelManager.currentLevelInfo.meshGradient,
                animationSpeed: 2.0
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
            VStack(spacing: 0) {
                // Top row
                HStack {
                    Image(systemName: "iphone.gen3.slash")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .semibold))
                        .frame(width: 32, height: 32)
                    Spacer()
                    HStack(spacing: 6) {
                        Image("gem") // Replace with your gem image asset name
                            .resizable()
                            .frame(width: 18, height: 18)
                        Text("\(levelManager.currentGems)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                    )

                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                
                
                // Level image center
                Image(levelManager.currentLevelInfo.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 8)
                
                Spacer()
                
                // BOTTOM WHITE STRIP
                HStack {
                    
                    // Bottom left - Flame and streak
                    HStack {
                        Image("flame.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Current Streak")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black.opacity(0.7))
                            HStack(alignment: .firstTextBaseline) {
                                Text("\(levelManager.currentStreak)")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.black)
                                Text("days")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.black.opacity(0.7))
                            }
                        }
                    }

                    Spacer()
                    
                    
                    // Bottom right - Free since date
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Free since")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black.opacity(0.7))
                        Text(appInstallDate)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                    }
                    
                    
                    
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 16)
                .background(
                    RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.07), radius: 4, x: 0, y: -2)
                )
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 250)
        .padding(.horizontal, 12)
    }
    
    private var appInstallDate: String {
        let installDate = UserDefaults.standard.object(forKey: "appInstallDate") as? Date ?? {
            let now = Date()
            UserDefaults.standard.set(now, forKey: "appInstallDate")
            return now
        }()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: installDate)
    }
    
    private func generateImage() {
        isGeneratingImage = true
        let cardView = cardForSharing

        let renderer = ImageRenderer(content: cardView)
        renderer.scale = 3.0 // High resolution

        if let uiImage = renderer.uiImage,
           let pngData = uiImage.pngData() {
            // Save to temp directory with .png extension
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent("level_card_\(UUID().uuidString).png")
            do {
                try pngData.write(to: fileURL)
                shareURL = fileURL
            } catch {
                print("Failed to write PNG: \(error)")
                shareURL = nil
            }
        } else {
            shareURL = nil
        }
        isGeneratingImage = false
    }

    private var cardForSharing: some View {
        // Standalone card view for sharing (without padding constraints)
        ZStack(alignment: .bottom) {
            // Full mesh gradient background
            MeshGradientView(
                colors: levelManager.currentLevelInfo.meshGradient,
                animationSpeed: 2.0
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
            VStack(spacing: 0) {
                // Top row
                HStack {
                    Image(systemName: "iphone.gen3.slash")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .semibold))
                        .frame(width: 32, height: 32)
                    Spacer()
                    HStack(spacing: 6) {
                        Image("gem")
                            .resizable()
                            .frame(width: 18, height: 18)
                        Text("\(levelManager.currentGems)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                    )
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                
                // Level image center
                Image(levelManager.currentLevelInfo.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 8)
                
                Spacer()
                
                // BOTTOM WHITE STRIP
                HStack {
                    // Bottom left - Flame and streak
                    HStack {
                        Image("flame.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Current Streak")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black.opacity(0.7))
                            HStack(alignment: .firstTextBaseline) {
                                Text("\(levelManager.currentStreak)")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.black)
                                Text("days")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.black.opacity(0.7))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Bottom right - Free since date
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Free since")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black.opacity(0.7))
                        Text(appInstallDate)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 16)
                .background(
                    RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.07), radius: 4, x: 0, y: -2)
                )
                .frame(maxWidth: .infinity)
            }
        }
        .frame(width: 350, height: 250) // Fixed size for sharing
    }
}

