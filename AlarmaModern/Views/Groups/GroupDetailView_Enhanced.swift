//
//  GroupDetailView.swift
//  AlarmaModern
//
//  Detail view with notifications, haptics, and animations
//

import SwiftUI
import SwiftData

struct GroupDetailViewEnhanced: View {
    @Environment(\.modelContext) private var modelContext
    let group: Group

    @State private var showingAddAlarm = false
    @State private var errorMessage: String?
    @State private var deletingAlarm: Alarm?

    var sortedAlarms: [Alarm] {
        group.alarms.sorted(by: { $0.time < $1.time })
    }

    var body: some View {
        List {
            if group.alarms.isEmpty {
                ContentUnavailableView(
                    "No Alarms",
                    systemImage: "alarm.slash",
                    description: Text("Add your first alarm to \"\(group.name)\"")
                )
            } else {
                ForEach(sortedAlarms) { alarm in
                    AlarmRowEnhanced(alarm: alarm, onToggle: {
                        Task {
                            await toggleAlarm(alarm)
                        }
                    })
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
                }
                .onDelete(perform: deleteAlarms)
            }
        }
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    HapticService.lightImpact()
                    showingAddAlarm = true
                } label: {
                    Label("Add Alarm", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddAlarm) {
            AlarmCreationView(group: group)
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
        .animation(AppTheme.springAnimation, value: group.alarms.count)
    }

    private func toggleAlarm(_ alarm: Alarm) async {
        alarm.isEnabled.toggle()

        do {
            try modelContext.save()

            if alarm.isEnabled {
                try await NotificationService.shared.scheduleNotification(for: alarm)
                HapticService.success()
            } else {
                NotificationService.shared.cancelNotification(for: alarm)
                HapticService.warning()
            }
        } catch {
            alarm.isEnabled.toggle() // Revert on error
            errorMessage = "Failed to update alarm: \(error.localizedDescription)"
            HapticService.error()
        }
    }

    private func deleteAlarms(at offsets: IndexSet) {
        HapticService.mediumImpact()

        for index in offsets {
            if index < sortedAlarms.count {
                let alarm = sortedAlarms[index]
                NotificationService.shared.cancelNotification(for: alarm)
                modelContext.delete(alarm)
            }
        }

        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to delete alarm: \(error.localizedDescription)"
            HapticService.error()
        }
    }
}

struct AlarmRowEnhanced: View {
    let alarm: Alarm
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            VStack(alignment: .leading, spacing: 6) {
                Text(alarm.timeString)
                    .font(AppTheme.title2Font)

                HStack(spacing: AppTheme.spacingM) {
                    Label(alarm.repeatDisplayString, systemImage: "repeat")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(.secondary)

                    Label(alarm.sound.displayName, systemImage: "speaker.wave.2")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Toggle("", isOn: .init(
                get: { alarm.isEnabled },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
            .tint(AppTheme.primaryColor)
        }
        .opacity(alarm.isEnabled ? 1.0 : 0.5)
        .animation(AppTheme.easeAnimation, value: alarm.isEnabled)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Alarm at \(alarm.timeString)")
        .accessibilityValue(alarm.isEnabled ? "Enabled" : "Disabled")
        .accessibilityHint("Double tap to toggle")
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Group.self, Alarm.self, configurations: config)

    let group = Group(name: "Morning Alarms")
    let alarm1 = Alarm(time: Date(), sound: .chime, repeatDays: [.monday, .wednesday, .friday], group: group)
    let alarm2 = Alarm(time: Date().addingTimeInterval(3600), sound: .bells, group: group)

    container.mainContext.insert(group)
    container.mainContext.insert(alarm1)
    container.mainContext.insert(alarm2)

    return NavigationStack {
        GroupDetailViewEnhanced(group: group)
    }
    .modelContainer(container)
}
