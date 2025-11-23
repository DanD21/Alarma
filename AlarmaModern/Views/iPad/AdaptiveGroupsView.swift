//
//  AdaptiveGroupsView.swift
//  AlarmaModern
//
//  iPad-optimized split view layout
//

import SwiftUI
import SwiftData

struct AdaptiveGroupsView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Query(sort: \Group.createdAt, order: .reverse) private var groups: [Group]

    @State private var selectedGroup: Group?
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn

    var body: some View {
        if sizeClass == .regular {
            // iPad: Split view
            NavigationSplitView(columnVisibility: $columnVisibility) {
                GroupsSidebarView(selectedGroup: $selectedGroup)
            } detail: {
                if let selectedGroup {
                    GroupDetailViewEnhanced(group: selectedGroup)
                } else {
                    EmptySelectionView()
                }
            }
            .navigationSplitViewStyle(.balanced)
        } else {
            // iPhone: Stack view
            NavigationStack {
                GroupsListView()
            }
        }
    }
}

struct GroupsSidebarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Group.createdAt, order: .reverse) private var groups: [Group]

    @Binding var selectedGroup: Group?
    @State private var showingAddGroup = false
    @State private var newGroupName = ""
    @State private var errorMessage: String?

    var body: some View {
        List(selection: $selectedGroup) {
            Section {
                if groups.isEmpty {
                    ContentUnavailableView(
                        "No Groups",
                        systemImage: "alarm.slash",
                        description: Text("Create your first alarm group")
                    )
                } else {
                    ForEach(groups) { group in
                        NavigationLink(value: group) {
                            GroupSidebarRow(group: group)
                        }
                    }
                    .onDelete(perform: deleteGroups)
                }
            } header: {
                HStack {
                    Text("Alarm Groups")
                    Spacer()
                    Button {
                        showingAddGroup = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
        }
        .navigationTitle("Alarma")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
        }
        .alert("New Group", isPresented: $showingAddGroup) {
            TextField("Group Name", text: $newGroupName)
            Button("Cancel", role: .cancel) {
                newGroupName = ""
            }
            Button("Create") {
                createGroup()
            }
        }
        .onAppear {
            if selectedGroup == nil, let firstGroup = groups.first {
                selectedGroup = firstGroup
            }
        }
    }

    private func createGroup() {
        guard !newGroupName.isEmpty else { return }

        let group = Group(name: newGroupName)
        modelContext.insert(group)

        do {
            try modelContext.save()
            selectedGroup = group
            newGroupName = ""
            HapticService.success()
        } catch {
            errorMessage = "Failed to create group"
            HapticService.error()
        }
    }

    private func deleteGroups(at offsets: IndexSet) {
        for index in offsets {
            let group = groups[index]
            if selectedGroup == group {
                selectedGroup = nil
            }
            modelContext.delete(group)
        }

        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to delete group"
        }
    }
}

struct GroupSidebarRow: View {
    let group: Group

    var body: some View {
        HStack {
            Image(systemName: "folder.fill")
                .foregroundStyle(group.isEnabled ? AppTheme.primaryColor : .secondary)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(AppTheme.headlineFont)

                Text("\(group.alarmsCount) alarm\(group.alarmsCount == 1 ? "" : "s")")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let nextTime = group.nextAlarmTime {
                Text(nextTime, style: .relative)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EmptySelectionView: View {
    var body: some View {
        ContentUnavailableView(
            "Select a Group",
            systemImage: "sidebar.left",
            description: Text("Choose an alarm group from the sidebar")
        )
    }
}

#Preview("iPad") {
    AdaptiveGroupsView()
        .modelContainer(for: [Group.self, Alarm.self], inMemory: true)
        .previewDevice("iPad Pro (12.9-inch) (6th generation)")
}

#Preview("iPhone") {
    AdaptiveGroupsView()
        .modelContainer(for: [Group.self, Alarm.self], inMemory: true)
        .previewDevice("iPhone 15 Pro")
}
