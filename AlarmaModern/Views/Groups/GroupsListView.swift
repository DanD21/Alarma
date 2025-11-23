//
//  GroupsListView.swift
//  AlarmaModern
//
//  Modern SwiftUI view with Swift 6 features
//

import SwiftUI
import SwiftData

struct GroupsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Group.createdAt, order: .reverse) private var groups: [Group]

    @State private var showingAddGroup = false
    @State private var newGroupName = ""
    @State private var errorMessage: String?

    var body: some View {
        List {
            if groups.isEmpty {
                ContentUnavailableView(
                    "No Alarm Groups",
                    systemImage: "alarm.slash",
                    description: Text("Create your first alarm group to get started")
                )
            } else {
                ForEach(groups) { group in
                    NavigationLink(value: group) {
                        GroupRow(group: group)
                    }
                }
                .onDelete(perform: deleteGroups)
            }
        }
        .navigationTitle("Alarms")
        .navigationDestination(for: Group.self) { group in
            GroupDetailView(group: group)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddGroup = true
                } label: {
                    Label("Add Group", systemImage: "plus")
                }
            }
        }
        .alert("New Alarm Group", isPresented: $showingAddGroup) {
            TextField("Group Name", text: $newGroupName)
            Button("Cancel", role: .cancel) {
                newGroupName = ""
            }
            Button("Create") {
                createGroup()
            }
        } message: {
            Text("Enter a name for your new alarm group")
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

    private func createGroup() {
        guard !newGroupName.isEmpty else { return }

        let group = Group(name: newGroupName)
        modelContext.insert(group)

        do {
            try modelContext.save()
            newGroupName = ""
        } catch {
            errorMessage = "Failed to create group: \(error.localizedDescription)"
        }
    }

    private func deleteGroups(at offsets: IndexSet) {
        for index in offsets {
            let group = groups[index]
            modelContext.delete(group)
        }

        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to delete group: \(error.localizedDescription)"
        }
    }
}

struct GroupRow: View {
    let group: Group

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.headline)

                HStack(spacing: 12) {
                    Label("\(group.alarmsCount)", systemImage: "alarm")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let nextAlarm = group.nextAlarmTime {
                        Label(
                            nextAlarm.formatted(date: .omitted, time: .shortened),
                            systemImage: "clock"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Toggle("", isOn: .init(
                get: { group.isEnabled },
                set: { newValue in
                    group.isEnabled = newValue
                    try? group.modelContext?.save()
                }
            ))
            .labelsHidden()
        }
        .opacity(group.isEnabled ? 1.0 : 0.5)
    }
}

#Preview {
    NavigationStack {
        GroupsListView()
    }
    .modelContainer(for: [Group.self, Alarm.self], inMemory: true)
}
