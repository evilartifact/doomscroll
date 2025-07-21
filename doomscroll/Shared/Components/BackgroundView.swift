//
//  BackgroundView.swift
//  doomscroll
//
//  Created by Rabin on 7/5/25.
//

import SwiftUI

//struct BackgroundView: View {
//    var body: some View {
//        LinearGradient(
//            gradient: Gradient(colors: [
//                Color(red: 0.07, green: 0.09, blue: 0.16), // Rich dark blue
//                        Color(red: 0.13, green: 0.11, blue: 0.18), // Deep indigo/purple
//                Color(red: 0.07, green: 0.09, blue: 0.16)
//            ]),
//            startPoint: .topLeading,
//            endPoint: .bottomTrailing
//        )
//        .ignoresSafeArea()
//    }
//}


struct BackgroundView: View {
    var body: some View {
        Color.black
        .ignoresSafeArea()
    }
}


#Preview {
    BackgroundView()
} 
