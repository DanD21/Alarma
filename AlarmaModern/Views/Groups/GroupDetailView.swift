//
//  GroupDetailView.swift
//  AlarmaModern
//
//  Detail view for a specific alarm group
//

import SwiftUI
import SwiftData

struct GroupDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let group: Group

    @State private var showingAddAlarm = false
    @State private var errorMessage: String?

    var body: some View {
        List {
            if group.alarms.isEmpty {
                ContentUnavailableView(
                    "No Alarms",
                    systemImage: "alarm.slash",
                    description: Text("Add your first alarm to \"\(group.name)\"")
                )
            } else {
                ForEach(group.alarms.sorted(by: { $0.time < $1.time })) { alarm in
                    AlarmRow(alarm: alarm)
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
    }

    private func deleteAlarms(at offsets: IndexSet) {
        for index in offsets {
            let sortedAlarms = group.alarms.sorted(by: { $0.time < $1.time })
            if index < sortedAlarms.count {
                let alarm = sortedAlarms[index]
                modelContext.delete(alarm)
            }
        }

        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to delete alarm: \(error.localizedDescription)"
        }
    }
}

struct AlarmRow: View {
    let alarm: Alarm

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(alarm.timeString)
                    .font(.title2)
                    .fontWeight(.semibold)

                HStack(spacing: 16) {
                    Label(alarm.repeatDisplayString, systemImage: "repeat")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Label(alarm.sound.displayName, systemImage: "speaker.wave.2")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Toggle("", isOn: .init(
                get: { alarm.isEnabled },
                set: { newValue in
                    alarm.isEnabled = newValue
                    try? alarm.modelContext?.save()
                }
            ))
            .labelsHidden()
        }
        .opacity(alarm.isEnabled ? 1.0 : 0.5)
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
        GroupDetailView(group: group)
    }
    .modelContainer(container)
}
