//
//  OnboardingView.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentPage = 0
    
    private let pageSpecs: [OnboardingPageSpec] = [
        OnboardingPageSpec(
            titleKey: "onboarding_page1_title",
            bodyKey: "onboarding_page1_body",
            icon: "chart.line.uptrend.xyaxis",
            color: Color(red: 1.0, green: 0.7, blue: 0.5)
        ),
        OnboardingPageSpec(
            titleKey: "onboarding_page2_title",
            bodyKey: "onboarding_page2_body",
            icon: "sparkles",
            color: Color(red: 1.0, green: 0.5, blue: 0.7)
        ),
        OnboardingPageSpec(
            titleKey: "onboarding_page3_title",
            bodyKey: "onboarding_page3_body",
            icon: "flame.fill",
            color: Color(red: 0.7, green: 0.5, blue: 1.0)
        )
    ]
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.95, blue: 0.9),
                    Color(red: 0.95, green: 0.9, blue: 1.0),
                    Color(red: 0.9, green: 0.95, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pageSpecs.count, id: \.self) { index in
                        OnboardingPageView(page: pageSpecs[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Page indicators
                HStack(spacing: 12) {
                    ForEach(0..<pageSpecs.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ?
                                  Color(red: 0.3, green: 0.2, blue: 0.4) :
                                  Color(red: 0.3, green: 0.2, blue: 0.4).opacity(0.3))
                            .frame(width: index == currentPage ? 12 : 8, height: index == currentPage ? 12 : 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.bottom, 40)
                
                // Navigation buttons
                HStack(spacing: 20) {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            Text("back")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.4))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.5))
                                .cornerRadius(20)
                        }
                    }
                    
                    Button(action: {
                        if currentPage < pageSpecs.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            isOnboardingComplete = true
                        }
                    }) {
                        Group {
                            if currentPage < pageSpecs.count - 1 {
                                Text("next")
                            } else {
                                Text("get_started")
                            }
                        }
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.7, blue: 0.5),
                                    Color(red: 1.0, green: 0.5, blue: 0.7)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
}

struct OnboardingPageSpec {
    let titleKey: String
    let bodyKey: String
    let icon: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPageSpec
    @State private var iconScale: CGFloat = 0.8
    @State private var iconRotation: Double = 0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animated icon
            ZStack {
                // Decorative circles
                Circle()
                    .fill(page.color.opacity(0.2))
                    .frame(width: 200, height: 200)
                
                Circle()
                    .fill(page.color.opacity(0.3))
                    .frame(width: 160, height: 160)
                
                // Main icon container
                ZStack {
                    RoundedRectangle(cornerRadius: 40)
                        .fill(
                            LinearGradient(
                                colors: [page.color, page.color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: page.icon)
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                }
                .scaleEffect(iconScale)
                .rotationEffect(.degrees(iconRotation))
            }
            .padding(.top, 60)
            
            // Text content
            VStack(spacing: 20) {
                Text(LocalizedStringKey(page.titleKey))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.3, green: 0.2, blue: 0.4))
                    .multilineTextAlignment(.center)
                
                Text(LocalizedStringKey(page.bodyKey))
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.6))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                iconScale = 1.0
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                iconRotation = 5
            }
        }
    }
}

#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
}
