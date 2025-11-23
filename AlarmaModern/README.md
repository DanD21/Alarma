# Alarma Modern - Swift 6 + SwiftUI

A modern reimplementation of the Alarma iOS app using Swift 6, SwiftUI, and SwiftData.

## 🎯 Features

- **Alarm Groups**: Organize alarms into groups for different routines
- **Recurring Alarms**: Set alarms for specific weekdays
- **Custom Sounds**: Choose from multiple alarm sounds
- **SwiftUI**: Modern declarative UI
- **SwiftData**: Apple's latest persistence framework
- **Full Test Coverage**: Unit and UI tests included

## 🏗️ Architecture

### Modern Swift 6 Features

- **Strict Concurrency**: Full actor isolation and `Sendable` conformance
- **Typed Throws**: Explicit error types for better error handling
- **@Observable**: New observation framework (replaces `ObservableObject`)
- **@ModelActor**: Thread-safe repository access
- **Swift Testing**: New testing framework with modern syntax

### Layer Structure

```
AlarmaModern/
├── App/                    # App entry point and root views
├── Models/                 # SwiftData models (Group, Alarm)
├── Repositories/           # Data access layer with actors
├── ViewModels/             # Business logic and state management
├── Views/                  # SwiftUI views
│   ├── Groups/
│   ├── Alarms/
│   ├── Onboarding/
│   └── Settings/
└── Tests/
    ├── UnitTests/          # Repository and model tests
    └── UITests/            # SwiftUI view tests
```

## 🔄 Key Improvements Over Original

### 1. Data Persistence
**Before**: Realm with manual mapping
```swift
class GroupRepositoryImp {
    lazy var realm = try! Realm()  // ⚠️ Force unwrap

    func save(group: Group) throws -> RealmGroup {
        let newGroup = group.toRealmEntity()
        try realm.write { realm.add(newGroup, update: true) }
        return newGroup
    }
}
```

**After**: SwiftData with type-safe queries
```swift
@ModelActor
actor GroupRepository {
    func save(_ group: Group) throws {
        modelContext.insert(group)
        try modelContext.save()
    }

    func fetchAll() throws -> [Group] {
        let descriptor = FetchDescriptor<Group>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
}
```

### 2. Error Handling
**Before**: Silent errors with `try?`
```swift
try? groupRepository.save(group: newGroup)
```

**After**: Typed errors with proper handling
```swift
enum GroupRepositoryError: Error, LocalizedError {
    case saveFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        }
    }
}
```

### 3. UI Architecture
**Before**: UIKit with XIBs and Coordinators
```swift
class GroupsListController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var onGroupSelect: ((Group) -> Void)?

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GroupsTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(with: groups[indexPath.row].toViewModel())
        return cell
    }
}
```

**After**: SwiftUI with declarative syntax
```swift
struct GroupsListView: View {
    @Query(sort: \Group.createdAt, order: .reverse)
    private var groups: [Group]

    var body: some View {
        List {
            ForEach(groups) { group in
                NavigationLink(value: group) {
                    GroupRow(group: group)
                }
            }
        }
    }
}
```

### 4. Navigation
**Before**: Coordinator pattern with closures
```swift
coordinator.finishFlow = { [weak self, weak coordinator] in
    isAuthorized = true
    self?.start()
    self?.removeDependency(coordinator)
}
```

**After**: SwiftUI NavigationStack
```swift
NavigationStack {
    GroupsListView()
}
.navigationDestination(for: Group.self) { group in
    GroupDetailView(group: group)
}
```

### 5. State Management
**Before**: Manual observation
```swift
class GroupsListController {
    var groups = [Group]()

    func refresh() {
        groups = groupRepository.fetchAllGroups()
        tableView.reloadData()
    }
}
```

**After**: SwiftData @Query with automatic updates
```swift
struct GroupsListView: View {
    @Query private var groups: [Group]
    // Automatically updates when data changes
}
```

### 6. Concurrency
**Before**: Completion handlers
```swift
func loadGroups(completion: @escaping ([Group]) -> Void) {
    DispatchQueue.global().async {
        let groups = self.repository.fetchAllGroups()
        DispatchQueue.main.async {
            completion(groups)
        }
    }
}
```

**After**: Async/await with actors
```swift
@MainActor
func loadGroups() async {
    do {
        groups = try await repository.fetchAll()
    } catch {
        errorMessage = error.localizedDescription
    }
}
```

## 🧪 Testing

### Unit Tests
```bash
# Test repositories
swift test --filter GroupRepositoryTests
swift test --filter AlarmRepositoryTests

# Test models
swift test --filter AlarmModelTests
swift test --filter GroupModelTests
```

### UI Tests
```bash
# Test groups functionality
swift test --filter GroupsListViewUITests

# Test alarm creation
swift test --filter AlarmCreationViewUITests
```

### Test Coverage Highlights

- **Repository Tests**: CRUD operations, filtering, sorting
- **Model Tests**: Business logic, computed properties, validation
- **UI Tests**: User flows, navigation, form interaction

## 🚀 Getting Started

### Requirements
- iOS 17.0+
- Xcode 15.0+
- Swift 6.0+

### Installation
1. Clone the repository
2. Open `Alarma.xcodeproj`
3. Build and run the `AlarmaModern` target

### Project Structure
```
AlarmaModern/
├── App/
│   └── AlarmaApp.swift          # App entry point with SwiftData setup
├── Models/
│   ├── Group.swift              # @Model for alarm groups
│   └── Alarm.swift              # @Model for alarms
├── Repositories/
│   ├── GroupRepository.swift    # @ModelActor for thread-safe access
│   └── AlarmRepository.swift
├── ViewModels/
│   ├── GroupsViewModel.swift    # @Observable for state
│   └── AlarmViewModel.swift
└── Views/
    ├── Groups/
    │   ├── GroupsListView.swift      # Main groups screen
    │   └── GroupDetailView.swift     # Group detail with alarms
    ├── Alarms/
    │   └── AlarmCreationView.swift   # Create/edit alarms
    ├── Onboarding/
    │   ├── OnboardingView.swift
    │   └── NotificationPermissionView.swift
    └── Settings/
        └── SettingsView.swift
```

## 📊 Comparison: UIKit vs SwiftUI

| Aspect | Original (UIKit) | Modern (SwiftUI) |
|--------|------------------|------------------|
| **Lines of Code** | ~1,200 | ~800 |
| **Data Layer** | Realm + Manual mapping | SwiftData (zero boilerplate) |
| **Navigation** | Coordinator pattern | NavigationStack |
| **State** | Manual refresh | Automatic @Query updates |
| **Concurrency** | Completion handlers | async/await |
| **Error Handling** | `try?` everywhere | Typed throws |
| **Testing** | XCTest (verbose) | Swift Testing (concise) |
| **Type Safety** | Force unwraps (`!`) | Optional handling |

## 🎨 SwiftUI Benefits

1. **Live Previews**: See UI changes instantly
2. **Less Code**: 33% reduction in code
3. **Type Safety**: Compiler-checked UI
4. **Automatic Updates**: No manual `reloadData()`
5. **Modern Patterns**: @Observable, @Query
6. **Better Accessibility**: Built-in support

## 🔒 Concurrency Safety

All repository operations use `@ModelActor` for thread-safe database access:

```swift
@ModelActor
actor GroupRepository {
    // All methods automatically isolated to model actor
    func save(_ group: Group) throws { ... }
}
```

## 📝 License

This is a learning project demonstrating modern iOS development practices.

---

**Migration Guide**: See original implementation in `/Alarma/Alarma/` for comparison with UIKit version.
