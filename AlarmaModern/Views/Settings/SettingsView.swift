//
//  SettingsView.swift
//  AlarmaModern
//
//  Settings view with modern SwiftUI
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @AppStorage("notificationSound") private var notificationSound = "Default"
    @AppStorage("snoozeMinutes") private var snoozeMinutes = 5

    var body: some View {
        List {
            Section("Alarm Settings") {
                Picker("Default Sound", selection: $notificationSound) {
                    Text("Default").tag("Default")
                    Text("Chime").tag("Chime")
                    Text("Bells").tag("Bells")
                    Text("Guitar").tag("Guitar")
                }

                Stepper("Snooze Duration: \(snoozeMinutes) min", value: $snoozeMinutes, in: 1...30)
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("2.0.0")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Build")
                    Spacer()
                    Text("Swift 6 + SwiftUI")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button("Reset Onboarding") {
                    hasCompletedOnboarding = false
                }
                .foregroundStyle(.blue)

                Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
