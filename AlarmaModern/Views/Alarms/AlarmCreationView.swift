//
//  AlarmCreationView.swift
//  AlarmaModern
//
//  Modern alarm creation view with proper form handling
//

import SwiftUI
import SwiftData

struct AlarmCreationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let group: Group

    @State private var selectedTime = Date()
    @State private var selectedSound: AlarmSound = .default
    @State private var loopSound = false
    @State private var selectedDays: Set<Weekday> = []
    @State private var errorMessage: String?
    @State private var isSaving = false
    @State private var shakeAmount: CGFloat = 0

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(
                        "Alarm Time",
                        selection: $selectedTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                } header: {
                    Label("Time", systemImage: "clock")
                }

                Section {
                    if selectedDays.isEmpty {
                        HStack {
                            Image(systemName: "repeat")
                                .foregroundStyle(.secondary)
                            Text("Never")
                                .foregroundStyle(.secondary)
                        }
                        .transition(.opacity)
                    } else {
                        HStack {
                            Image(systemName: "repeat")
                                .foregroundStyle(AppTheme.primaryColor)
                            Text(repeatDisplayString)
                                .foregroundStyle(AppTheme.primaryColor)
                                .fontWeight(.medium)
                        }
                        .transition(.opacity)
                    }

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(Weekday.allCases) { day in
                            DayButton(
                                day: day,
                                isSelected: selectedDays.contains(day)
                            ) {
                                withAnimation(AppTheme.springAnimation) {
                                    toggleDay(day)
                                }
                                HapticService.selection()
                            }
                        }
                    }
                    .padding(.vertical, AppTheme.spacingS)
                } header: {
                    Label("Repeat", systemImage: "calendar")
                }

                Section {
                    Picker("Sound", selection: $selectedSound) {
                        ForEach(AlarmSound.allCases) { sound in
                            Text(sound.displayName).tag(sound)
                        }
                    }
                    .onChange(of: selectedSound) { _, _ in
                        HapticService.selection()
                    }

                    Toggle(isOn: $loopSound) {
                        Label("Loop Sound", systemImage: "repeat.1")
                    }
                    .onChange(of: loopSound) { _, _ in
                        HapticService.selection()
                    }
                } header: {
                    Label("Sound", systemImage: "speaker.wave.2")
                }
            }
            .navigationTitle("New Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        HapticService.lightImpact()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveAlarm()
                        }
                    }
                    .disabled(isSaving)
                    .overlay {
                        if isSaving {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
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
            .shake(animatableData: shakeAmount)
        }
    }

    private func toggleDay(_ day: Weekday) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }

    private func saveAlarm() async {
        isSaving = true

        let alarm = Alarm(
            time: selectedTime,
            isEnabled: true,
            sound: selectedSound,
            loopSound: loopSound,
            repeatDays: Array(selectedDays),
            group: group
        )

        modelContext.insert(alarm)

        do {
            try modelContext.save()

            // Schedule notification
            do {
                try await NotificationService.shared.scheduleNotification(for: alarm)
                HapticService.success()

                withAnimation(AppTheme.easeAnimation) {
                    dismiss()
                }
            } catch {
                // Alarm saved but notification failed
                HapticService.warning()
                errorMessage = "Alarm created but notification scheduling failed. Please check notification permissions."
                isSaving = false
            }
        } catch {
            HapticService.error()
            errorMessage = "Failed to create alarm: \(error.localizedDescription)"
            isSaving = false

            withAnimation(.default) {
                shakeAmount += 1
            }
        }
    }

    private var repeatDisplayString: String {
        guard !selectedDays.isEmpty else { return "Never" }

        if selectedDays.count == 7 {
            return "Every day"
        }

        let weekdays: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday]
        if selectedDays == weekdays {
            return "Weekdays"
        }

        let weekends: Set<Weekday> = [.saturday, .sunday]
        if selectedDays == weekends {
            return "Weekends"
        }

        return selectedDays.sorted(by: { $0.rawValue < $1.rawValue })
            .map { $0.shortName }
            .joined(separator: ", ")
    }
}

struct DayButton: View {
    let day: Weekday
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(day.shortName)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.spacingS)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusS)
                        .fill(isSelected ? AppTheme.primaryColor.gradient : Color(.systemGray5))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusS)
                        .stroke(
                            isSelected ? AppTheme.primaryColor : .clear,
                            lineWidth: 2
                        )
                )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(AppTheme.springAnimation, value: isSelected)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Group.self, Alarm.self, configurations: config)

    let group = Group(name: "Morning Alarms")
    container.mainContext.insert(group)

    return AlarmCreationView(group: group)
        .modelContainer(container)
}
