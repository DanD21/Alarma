//
//  GroupsViewModel.swift
//  AlarmaModern
//
//  Modern ViewModel using @Observable and Swift 6 concurrency
//

import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class GroupsViewModel {
    private let modelContext: ModelContext
    private var repository: GroupRepository?

    var groups: [Group] = []
    var errorMessage: String?
    var isLoading = false

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        Task {
            self.repository = GroupRepository(modelContainer: modelContext.container)
            await loadGroups()
        }
    }

    func loadGroups() async {
        isLoading = true
        errorMessage = nil

        do {
            guard let repository = repository else { return }
            groups = try await repository.fetchAll()
        } catch {
            errorMessage = "Failed to load groups: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func createGroup(name: String) async {
        guard !name.isEmpty else {
            errorMessage = "Group name cannot be empty"
            return
        }

        let group = Group(name: name)
        modelContext.insert(group)

        do {
            try modelContext.save()
            await loadGroups()
        } catch {
            errorMessage = "Failed to create group: \(error.localizedDescription)"
        }
    }

    func deleteGroup(_ group: Group) async {
        modelContext.delete(group)

        do {
            try modelContext.save()
            await loadGroups()
        } catch {
            errorMessage = "Failed to delete group: \(error.localizedDescription)"
        }
    }

    func toggleGroup(_ group: Group) async {
        group.isEnabled.toggle()

        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to update group: \(error.localizedDescription)"
        }
    }

    func groupsWithActiveAlarms() -> [Group] {
        groups.filter { $0.isEnabled && $0.hasAlarms }
    }
}
