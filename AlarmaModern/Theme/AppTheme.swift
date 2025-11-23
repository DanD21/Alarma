//
//  AppTheme.swift
//  AlarmaModern
//
//  Comprehensive design system for consistent UI
//

import SwiftUI

enum AppTheme {
    // MARK: - Colors
    static let primaryColor = Color.accentColor
    static let secondaryColor = Color.secondary
    static let successColor = Color.green
    static let errorColor = Color.red
    static let warningColor = Color.orange

    static let cardBackground = Color(.systemBackground)
    static let groupedBackground = Color(.systemGroupedBackground)
    static let secondaryGroupedBackground = Color(.secondarySystemGroupedBackground)

    // MARK: - Typography
    static let largeTitleFont = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let titleFont = Font.system(.title, design: .rounded).weight(.semibold)
    static let title2Font = Font.system(.title2, design: .rounded).weight(.semibold)
    static let headlineFont = Font.system(.headline, design: .rounded)
    static let bodyFont = Font.system(.body, design: .default)
    static let captionFont = Font.system(.caption, design: .default)

    // MARK: - Spacing
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32

    // MARK: - Corner Radius
    static let cornerRadiusS: CGFloat = 8
    static let cornerRadiusM: CGFloat = 12
    static let cornerRadiusL: CGFloat = 16
    static let cornerRadiusXL: CGFloat = 24

    // MARK: - Shadows
    static let shadowRadius: CGFloat = 8
    static let shadowOpacity: CGFloat = 0.1

    // MARK: - Animation
    static let springAnimation = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let easeAnimation = Animation.easeInOut(duration: 0.2)
    static let slowAnimation = Animation.easeInOut(duration: 0.4)
}

// MARK: - View Modifiers

struct CardModifier: ViewModifier {
    var padding: CGFloat = AppTheme.spacingM

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadiusM)
            .shadow(
                color: Color.black.opacity(AppTheme.shadowOpacity),
                radius: AppTheme.shadowRadius,
                x: 0,
                y: 2
            )
    }
}

struct GradientBackgroundModifier: ViewModifier {
    let colors: [Color]

    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0
            )
        )
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle(padding: CGFloat = AppTheme.spacingM) -> some View {
        modifier(CardModifier(padding: padding))
    }

    func gradientBackground(colors: [Color]) -> some View {
        modifier(GradientBackgroundModifier(colors: colors))
    }

    func shake(animatableData: CGFloat) -> some View {
        modifier(ShakeEffect(animatableData: animatableData))
    }
}

// MARK: - Reusable Components

struct LoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: AppTheme.spacingM) {
            ProgressView()
                .scaleEffect(1.5)

            Text(message)
                .font(AppTheme.bodyFont)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.groupedBackground)
    }
}

struct ErrorView: View {
    let message: String
    let retry: (() -> Void)?

    var body: some View {
        VStack(spacing: AppTheme.spacingM) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(AppTheme.errorColor)

            Text("Something went wrong")
                .font(AppTheme.titleFont)

            Text(message)
                .font(AppTheme.bodyFont)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.spacingL)

            if let retry {
                Button(action: retry) {
                    Label("Try Again", systemImage: "arrow.clockwise")
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(.white)
                        .padding(.horizontal, AppTheme.spacingL)
                        .padding(.vertical, AppTheme.spacingS)
                        .background(AppTheme.primaryColor)
                        .cornerRadius(AppTheme.cornerRadiusS)
                }
                .padding(.top, AppTheme.spacingS)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.groupedBackground)
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.headlineFont)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.spacingM)
                .background(AppTheme.primaryColor)
                .cornerRadius(AppTheme.cornerRadiusM)
        }
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.headlineFont)
                .foregroundStyle(AppTheme.primaryColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.spacingM)
                .background(AppTheme.primaryColor.opacity(0.1))
                .cornerRadius(AppTheme.cornerRadiusM)
        }
    }
}
