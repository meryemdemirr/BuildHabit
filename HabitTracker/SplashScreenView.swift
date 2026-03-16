//
//  SplashScreenView.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var textOffset: CGFloat = 50
    @State private var textOpacity: Double = 0
    @State private var cloudOffset1: CGFloat = -100
    @State private var cloudOffset2: CGFloat = 100
    @State private var starRotation: Double = 0
    
    var body: some View {
        ZStack {
            // Soft pastel gradient background
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.95, blue: 0.9), // Soft peach
                    Color(red: 0.95, green: 0.9, blue: 1.0), // Soft lavender
                    Color(red: 0.9, green: 0.95, blue: 1.0)  // Soft blue
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Decorative cartoon elements
            VStack {
                Spacer()
                
                // Floating clouds
                HStack {
                    CloudShape()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 80, height: 50)
                        .offset(x: cloudOffset1, y: -200)
                    
                    Spacer()
                    
                    CloudShape()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 60, height: 40)
                        .offset(x: cloudOffset2, y: -150)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            
            // Rounded decorative shapes
            VStack {
                HStack {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.8, blue: 0.8).opacity(0.3))
                        .frame(width: 120, height: 120)
                        .offset(x: -50, y: 100)
                    
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color(red: 0.8, green: 0.9, blue: 1.0).opacity(0.3))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(45))
                        .offset(x: 50, y: 80)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            
            // Main content
            VStack(spacing: 30) {
                // Animated logo with star decoration
                ZStack {
                    // Decorative stars
                    StarShape()
                        .fill(Color(red: 1.0, green: 0.9, blue: 0.4).opacity(0.8))
                        .frame(width: 30, height: 30)
                        .offset(x: -60, y: -60)
                        .rotationEffect(.degrees(starRotation))
                    
                    StarShape()
                        .fill(Color(red: 1.0, green: 0.7, blue: 0.7).opacity(0.8))
                        .frame(width: 25, height: 25)
                        .offset(x: 70, y: -50)
                        .rotationEffect(.degrees(-starRotation))
                    
                    // Main logo icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.7, blue: 0.5),
                                        Color(red: 1.0, green: 0.5, blue: 0.7)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                }
                
                // App name with animation
                VStack(spacing: 8) {
                    Text("HabitTracker")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.4))
                        .offset(y: textOffset)
                        .opacity(textOpacity)
                    
                    Text("Build Better Habits")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.6))
                        .offset(y: textOffset)
                        .opacity(textOpacity)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
                textOffset = 0
                textOpacity = 1.0
            }
            
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                cloudOffset1 = -80
                cloudOffset2 = 80
            }
            
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                starRotation = 360
            }
        }
    }
}

// Custom cloud shape
struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Create a fluffy cloud shape
        path.move(to: CGPoint(x: width * 0.2, y: height * 0.5))
        path.addQuadCurve(to: CGPoint(x: width * 0.4, y: height * 0.2), control: CGPoint(x: width * 0.3, y: height * 0.3))
        path.addQuadCurve(to: CGPoint(x: width * 0.6, y: height * 0.2), control: CGPoint(x: width * 0.5, y: height * 0.1))
        path.addQuadCurve(to: CGPoint(x: width * 0.8, y: height * 0.5), control: CGPoint(x: width * 0.7, y: height * 0.3))
        path.addQuadCurve(to: CGPoint(x: width * 0.6, y: height * 0.8), control: CGPoint(x: width * 0.7, y: height * 0.7))
        path.addQuadCurve(to: CGPoint(x: width * 0.4, y: height * 0.8), control: CGPoint(x: width * 0.5, y: height * 0.9))
        path.addQuadCurve(to: CGPoint(x: width * 0.2, y: height * 0.5), control: CGPoint(x: width * 0.3, y: height * 0.7))
        path.closeSubpath()
        
        return path
    }
}

// Custom star shape
struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        let points = 5
        let angle = Double.pi * 2 / Double(points)
        let innerRadius = radius * 0.4
        
        for i in 0..<points * 2 {
            let currentAngle = angle * Double(i) / 2 - Double.pi / 2
            let r = i % 2 == 0 ? radius : innerRadius
            let x = center.x + CGFloat(cos(currentAngle)) * r
            let y = center.y + CGFloat(sin(currentAngle)) * r
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    SplashScreenView()
}
