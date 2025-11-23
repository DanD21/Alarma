//
//  AlarmLiveActivity.swift
//  AlarmaModern
//
//  Live Activities for Lock Screen countdown
//

import ActivityKit
import SwiftUI

// MARK: - Activity Attributes

struct AlarmActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var alarmTime: Date
        var groupName: String
        var isEnabled: Bool
    }

    var alarmID: String
}

// MARK: - Live Activity Widget

@available(iOS 16.1, *)
struct AlarmLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AlarmActivityAttributes.self) { context in
            // Lock Screen presentation
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded presentation
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "alarm.fill")
                        .foregroundStyle(.orange)
                        .font(.title2)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.alarmTime, style: .timer)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 90)
                        .monospacedDigit()
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(context.state.groupName)
                                .font(.headline)
                            Text("Next Alarm")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.top, 8)
                }
            } compactLeading: {
                Image(systemName: "alarm.fill")
                    .foregroundStyle(.orange)
            } compactTrailing: {
                Text(context.state.alarmTime, style: .timer)
                    .font(.caption2)
                    .monospacedDigit()
                    .frame(width: 50)
            } minimal: {
                Image(systemName: "alarm.fill")
                    .foregroundStyle(.orange)
            }
        }
    }
}

// MARK: - Lock Screen View

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<AlarmActivityAttributes>

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "alarm.fill")
                .foregroundStyle(.orange)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text("Next Alarm")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(context.state.groupName)
                    .font(.headline)
            }

            Spacer()

            Text(context.state.alarmTime, style: .timer)
                .font(.title2)
                .fontWeight(.bold)
                .monospacedDigit()
        }
        .padding(12)
    }
}

// MARK: - Live Activity Manager

@MainActor
class LiveActivityManager {
    static let shared = LiveActivityManager()

    private init() {}

    func startActivity(for alarm: Alarm) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled")
            return
        }

        let attributes = AlarmActivityAttributes(alarmID: alarm.id.uuidString)
        let state = AlarmActivityAttributes.ContentState(
            alarmTime: alarm.time,
            groupName: alarm.group?.name ?? "Alarm",
            isEnabled: alarm.isEnabled
        )

        do {
            let activity = try Activity<AlarmActivityAttributes>.request(
                attributes: attributes,
                contentState: state,
                pushType: nil
            )
            print("Live Activity started: \(activity.id)")
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    func updateActivity(for alarm: Alarm) async {
        for activity in Activity<AlarmActivityAttributes>.activities {
            if activity.attributes.alarmID == alarm.id.uuidString {
                let state = AlarmActivityAttributes.ContentState(
                    alarmTime: alarm.time,
                    groupName: alarm.group?.name ?? "Alarm",
                    isEnabled: alarm.isEnabled
                )

                await activity.update(using: state)
                print("Live Activity updated")
                return
            }
        }
    }

    func endActivity(for alarm: Alarm) async {
        for activity in Activity<AlarmActivityAttributes>.activities {
            if activity.attributes.alarmID == alarm.id.uuidString {
                await activity.end(dismissalPolicy: .immediate)
                print("Live Activity ended")
                return
            }
        }
    }

    func endAllActivities() async {
        for activity in Activity<AlarmActivityAttributes>.activities {
            await activity.end(dismissalPolicy: .immediate)
        }
    }
}
