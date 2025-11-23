//
//  NotificationPermissionView.swift
//  AlarmaModern
//
//  Notification permission request view
//

import SwiftUI
import UserNotifications

struct NotificationPermissionView: View {
    @Binding var hasGrantedNotifications: Bool

    @State private var showingDeniedAlert = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "bell.badge.fill")
                .font(.system(size: 100))
                .foregroundStyle(.orange.gradient)

            VStack(spacing: 16) {
                Text("Enable Notifications")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Alarma needs notification permissions to wake you up at the right time")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            Button {
                requestNotificationPermission()
            } label: {
                Text("Enable Notifications")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)

            Button("Not Now") {
                hasGrantedNotifications = true
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 32)
        }
        .alert("Notifications Denied", isPresented: $showingDeniedAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Skip", role: .cancel) {
                hasGrantedNotifications = true
            }
        } message: {
            Text("Please enable notifications in Settings to receive alarm alerts")
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    hasGrantedNotifications = true
                } else {
                    showingDeniedAlert = true
                }
            }
        }
    }
}

#Preview {
    NotificationPermissionView(hasGrantedNotifications: .constant(false))
}
