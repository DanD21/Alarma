//
//  HaloEffects.swift
//  AlarmaModern
//
//  Stunning visual halo effects for alarms
//

import SwiftUI

// MARK: - Halo Effect Modifier

struct HaloEffect: ViewModifier {
    let color: Color
    let intensity: CGFloat
    let isAnimating: Bool

    @State private var pulseAmount: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(color.opacity(0.2 * intensity))
                        .blur(radius: 20)
                        .scaleEffect(pulseAmount * 1.5)

                    // Middle glow
                    Circle()
                        .fill(color.opacity(0.3 * intensity))
                        .blur(radius: 10)
                        .scaleEffect(pulseAmount * 1.2)

                    // Inner glow
                    Circle()
                        .fill(color.opacity(0.4 * intensity))
                        .blur(radius: 5)
                        .scaleEffect(pulseAmount)
                }
            )
            .onAppear {
                if isAnimating {
                    withAnimation(
                        .easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true)
                    ) {
                        pulseAmount = 1.3
                    }
                }
            }
    }
}

// MARK: - Urgent Alarm Pulse

struct UrgentPulseEffect: ViewModifier {
    let isUrgent: Bool

    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.8

    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if isUrgent {
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM)
                            .stroke(Color.orange, lineWidth: 3)
                            .scaleEffect(pulseScale)
                            .opacity(pulseOpacity)
                    }
                }
            )
            .onAppear {
                if isUrgent {
                    withAnimation(
                        .easeOut(duration: 1.5)
                        .repeatForever(autoreverses: false)
                    ) {
                        pulseScale = 1.2
                        pulseOpacity = 0.0
                    }
                }
            }
    }
}

// MARK: - Next Alarm Highlight

struct NextAlarmHighlight: ViewModifier {
    let isNext: Bool

    @State private var glowIntensity: CGFloat = 0.5
    @State private var rotationAngle: Double = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if isNext {
                        // Rotating gradient halo
                        AngularGradient(
                            colors: [
                                .clear,
                                AppTheme.primaryColor.opacity(0.3),
                                .clear,
                                AppTheme.primaryColor.opacity(0.3),
                                .clear
                            ],
                            center: .center,
                            angle: .degrees(rotationAngle)
                        )
                        .blur(radius: 20)
                        .allowsHitTesting(false)
                    }
                }
            )
            .overlay(
                Group {
                    if isNext {
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        AppTheme.primaryColor,
                                        AppTheme.primaryColor.opacity(0.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .shadow(
                                color: AppTheme.primaryColor.opacity(glowIntensity),
                                radius: 10
                            )
                    }
                }
            )
            .onAppear {
                if isNext {
                    withAnimation(
                        .linear(duration: 3.0)
                        .repeatForever(autoreverses: false)
                    ) {
                        rotationAngle = 360
                    }

                    withAnimation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                    ) {
                        glowIntensity = 0.8
                    }
                }
            }
    }
}

// MARK: - Particle Burst Effect

struct ParticleBurst: View {
    let count: Int
    let color: Color

    @State private var particleStates: [ParticleState] = []

    var body: some View {
        ZStack {
            ForEach(particleStates.indices, id: \.self) { index in
                Circle()
                    .fill(color)
                    .frame(width: 4, height: 4)
                    .offset(
                        x: particleStates[index].offsetX,
                        y: particleStates[index].offsetY
                    )
                    .opacity(particleStates[index].opacity)
            }
        }
        .onAppear {
            setupParticles()
            animateParticles()
        }
    }

    private func setupParticles() {
        particleStates = (0..<count).map { index in
            let angle = (Double(index) / Double(count)) * 2 * .pi
            return ParticleState(
                offsetX: 0,
                offsetY: 0,
                opacity: 1.0,
                angle: angle
            )
        }
    }

    private func animateParticles() {
        withAnimation(.easeOut(duration: 1.0)) {
            for index in particleStates.indices {
                let distance: CGFloat = 50
                particleStates[index].offsetX = cos(particleStates[index].angle) * distance
                particleStates[index].offsetY = sin(particleStates[index].angle) * distance
                particleStates[index].opacity = 0
            }
        }
    }

    private struct ParticleState {
        var offsetX: CGFloat
        var offsetY: CGFloat
        var opacity: Double
        let angle: Double
    }
}

// MARK: - Shimmer Effect

struct ShimmerEffect: ViewModifier {
    @State private var shimmerPhase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.3),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: shimmerPhase)
                .allowsHitTesting(false)
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 2.0)
                    .repeatForever(autoreverses: false)
                ) {
                    shimmerPhase = 300
                }
            }
    }
}

// MARK: - Glow Border

struct GlowBorder: ViewModifier {
    let color: Color
    let lineWidth: CGFloat
    let intensity: CGFloat

    @State private var glowAmount: CGFloat = 0.5

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM)
                    .stroke(color, lineWidth: lineWidth)
                    .shadow(color: color.opacity(glowAmount * intensity), radius: 10)
                    .shadow(color: color.opacity(glowAmount * intensity), radius: 20)
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
                ) {
                    glowAmount = 1.0
                }
            }
    }
}

// MARK: - View Extensions

extension View {
    /// Adds a pulsing halo effect around the view
    func haloEffect(color: Color = .orange, intensity: CGFloat = 1.0, isAnimating: Bool = true) -> some View {
        modifier(HaloEffect(color: color, intensity: intensity, isAnimating: isAnimating))
    }

    /// Adds urgent pulse effect for alarms ringing soon
    func urgentPulse(isUrgent: Bool) -> some View {
        modifier(UrgentPulseEffect(isUrgent: isUrgent))
    }

    /// Highlights the next upcoming alarm
    func nextAlarmHighlight(isNext: Bool) -> some View {
        modifier(NextAlarmHighlight(isNext: isNext))
    }

    /// Adds a shimmer animation
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }

    /// Adds a glowing border
    func glowBorder(color: Color, lineWidth: CGFloat = 2, intensity: CGFloat = 1.0) -> some View {
        modifier(GlowBorder(color: color, lineWidth: lineWidth, intensity: intensity))
    }
}

// MARK: - Preset Halo Styles

struct HaloStyle {
    static func urgent() -> some ViewModifier {
        UrgentPulseEffect(isUrgent: true)
    }

    static func nextAlarm() -> some ViewModifier {
        NextAlarmHighlight(isNext: true)
    }

    static func subtle(color: Color = .blue) -> some ViewModifier {
        HaloEffect(color: color, intensity: 0.3, isAnimating: true)
    }

    static func intense(color: Color = .orange) -> some ViewModifier {
        HaloEffect(color: color, intensity: 1.0, isAnimating: true)
    }
}

// MARK: - Success Particle Burst View

struct SuccessParticleBurst: View {
    @State private var showParticles = false

    var body: some View {
        ZStack {
            if showParticles {
                ParticleBurst(count: 12, color: .green)
            }
        }
        .onAppear {
            showParticles = true
        }
    }
}

// MARK: - Example Usage in Previews

#Preview("Halo Effects") {
    VStack(spacing: 40) {
        // Urgent alarm
        Text("Urgent Alarm")
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(AppTheme.cornerRadiusM)
            .urgentPulse(isUrgent: true)

        // Next alarm highlight
        Text("Next Alarm")
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(AppTheme.cornerRadiusM)
            .nextAlarmHighlight(isNext: true)

        // Subtle halo
        Text("Normal Alarm")
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(AppTheme.cornerRadiusM)
            .haloEffect(color: .blue, intensity: 0.5)

        // Shimmer effect
        Text("Shimmer")
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(AppTheme.cornerRadiusM)
            .shimmer()

        // Glow border
        Text("Glow Border")
            .padding()
            .background(Color.pink.opacity(0.1))
            .cornerRadius(AppTheme.cornerRadiusM)
            .glowBorder(color: .pink)
    }
    .padding()
}
