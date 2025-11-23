//
//  AlarmaApp.swift
//  AlarmaModern
//
//  Modern Swift 6 + SwiftUI implementation
//

import SwiftUI
import SwiftData

@main
struct AlarmaApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([
                Group.self,
                Alarm.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(modelContainer)
    }
}

/// Root view that handles onboarding and main app navigation
struct AppRootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasGrantedNotifications") private var hasGrantedNotifications = false

    var body: some View {
        if !hasCompletedOnboarding {
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
        } else if !hasGrantedNotifications {
            NotificationPermissionView(hasGrantedNotifications: $hasGrantedNotifications)
        } else {
            MainTabView()
        }
    }
}

/// Main tab bar view
struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                GroupsListView()
            }
            .tabItem {
                Label("Alarms", systemImage: "alarm.fill")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
    }
}
