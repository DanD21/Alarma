//
//  HapticService.swift
//  AlarmaModern
//
//  Haptic feedback service for better UX
//

import UIKit

@MainActor
struct HapticService {
    /// Success feedback (alarm created, saved, etc.)
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// Error feedback (failed to save, etc.)
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    /// Warning feedback (alarm disabled, etc.)
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    /// Selection feedback (toggling days, switches)
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    /// Light impact (button taps)
    static func lightImpact() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    /// Medium impact (swipe actions)
    static func mediumImpact() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    /// Heavy impact (important actions)
    static func heavyImpact() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
}
