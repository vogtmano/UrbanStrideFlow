import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Goals") {
                    Stepper(value: $viewModel.settings.dailyStepGoal, in: 1_000...30_000, step: 500) {
                        HStack {
                            Text("Daily step goal")
                            Spacer()
                            Text(viewModel.settings.dailyStepGoal.formatted())
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onChange(of: viewModel.settings.dailyStepGoal) { _, _ in
                        viewModel.saveSettings()
                    }
                }

                Section("Movement Reminders") {
                    Toggle("Enable reminders", isOn: Binding(
                        get: { viewModel.settings.remindersEnabled },
                        set: { enabled in
                            Task { await viewModel.updateReminders(enabled: enabled) }
                        }
                    ))

                    Stepper(value: $viewModel.settings.workStartHour, in: 0...23) {
                        Text("Start: \(timeString(hour: viewModel.settings.workStartHour, minute: viewModel.settings.workStartMinute))")
                    }
                    .onChange(of: viewModel.settings.workStartHour) { _, _ in viewModel.saveSettings() }

                    Stepper(value: $viewModel.settings.workEndHour, in: 1...23) {
                        Text("End: \(timeString(hour: viewModel.settings.workEndHour, minute: viewModel.settings.workEndMinute))")
                    }
                    .onChange(of: viewModel.settings.workEndHour) { _, _ in viewModel.saveSettings() }

                    Button {
                        Task { await viewModel.scheduleReminders() }
                    } label: {
                        Label("Schedule Reminders", systemImage: "bell.badge.fill")
                    }

                    LabeledContent("Notification status", value: viewModel.notificationStatusText)
                }

                Section("HealthKit") {
                    LabeledContent("Permission status", value: viewModel.healthStatus.rawValue)

                    Button {
                        Task { await viewModel.requestHealthPermissions() }
                    } label: {
                        Label("Request HealthKit Permissions", systemImage: "heart.text.square.fill")
                    }

                    Text("When HealthKit is unavailable or permission is denied, the app uses demo values so the simulator remains useful.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .task {
                await viewModel.refreshNotificationStatus()
            }
        }
    }

    private func timeString(hour: Int, minute: Int) -> String {
        String(format: "%02d:%02d", hour, minute)
    }
}
