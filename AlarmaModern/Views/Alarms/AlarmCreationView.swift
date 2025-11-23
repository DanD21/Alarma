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

    var body: some View {
        NavigationStack {
            Form {
                Section("Time") {
                    DatePicker(
                        "Alarm Time",
                        selection: $selectedTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.wheel)
                }

                Section("Repeat") {
                    if selectedDays.isEmpty {
                        Text("Never")
                            .foregroundStyle(.secondary)
                    } else {
                        Text(repeatDisplayString)
                            .foregroundStyle(.secondary)
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
                                toggleDay(day)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Sound") {
                    Picker("Sound", selection: $selectedSound) {
                        ForEach(AlarmSound.allCases) { sound in
                            Text(sound.displayName).tag(sound)
                        }
                    }

                    Toggle("Loop Sound", isOn: $loopSound)
                }
            }
            .navigationTitle("New Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAlarm()
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
        }
    }

    private func toggleDay(_ day: Weekday) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }

    private func saveAlarm() {
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
            dismiss()
        } catch {
            errorMessage = "Failed to create alarm: \(error.localizedDescription)"
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
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.accentColor : Color(.systemGray5))
                )
        }
        .buttonStyle(.plain)
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
