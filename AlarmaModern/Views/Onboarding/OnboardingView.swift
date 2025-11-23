//
//  OnboardingView.swift
//  AlarmaModern
//
//  Modern onboarding flow with SwiftUI
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool

    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to Alarma",
            description: "Organize your alarms into groups for better management",
            imageName: "alarm.fill",
            color: .blue
        ),
        OnboardingPage(
            title: "Smart Groups",
            description: "Create alarm groups for work, weekends, or any routine",
            imageName: "folder.fill",
            color: .green
        ),
        OnboardingPage(
            title: "Custom Schedules",
            description: "Set different sounds and repeat patterns for each alarm",
            imageName: "calendar",
            color: .orange
        )
    ]

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button {
                if currentPage < pages.count - 1 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    hasCompletedOnboarding = true
                }
            } label: {
                Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)

            if currentPage < pages.count - 1 {
                Button("Skip") {
                    hasCompletedOnboarding = true
                }
                .foregroundStyle(.secondary)
                .padding(.bottom, 16)
            }
        }
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: page.imageName)
                .font(.system(size: 100))
                .foregroundStyle(page.color.gradient)

            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
