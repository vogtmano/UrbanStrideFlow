import SwiftUI

struct StretchSessionView: View {
    @StateObject private var viewModel = StretchSessionViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var didAwardCompletion = false
    @State private var completionResult: StretchCompletionResult?

    let onCompleted: ([String], Int) -> StretchCompletionResult

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 12)

            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.18), lineWidth: 16)
                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(.teal, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 8) {
                    Text(viewModel.formattedRemainingTime)
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                    Text("3-minute reset")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 230, height: 230)

            if let completionResult {
                completionCard(result: completionResult)
            } else {
                exerciseCard
                exerciseList
                controls
            }

            Spacer(minLength: 12)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Stretch Session")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.state) { _, state in
            guard state == .finished, !didAwardCompletion else { return }
            didAwardCompletion = true
            completionResult = onCompleted(viewModel.completedExerciseNames, max(viewModel.elapsedSeconds, 180))
        }
    }

    private var exerciseCard: some View {
        VStack(spacing: 12) {
            Image(systemName: viewModel.currentExercise.symbolName)
                .font(.largeTitle)
                .foregroundStyle(.teal)
            Text(viewModel.currentExercise.name)
                .font(.title2.weight(.bold))
            Text(viewModel.currentExercise.instruction)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var exerciseList: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(viewModel.exercises) { exercise in
                Label(exercise.name, systemImage: exercise.symbolName)
                    .font(.subheadline)
                    .foregroundStyle(exercise.id == viewModel.currentExercise.id ? .teal : .secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var controls: some View {
        HStack(spacing: 12) {
            switch viewModel.state {
            case .ready:
                Button {
                    viewModel.start()
                } label: {
                    Label("Start", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

            case .running:
                Button {
                    viewModel.pause()
                } label: {
                    Label("Pause", systemImage: "pause.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    viewModel.finish()
                } label: {
                    Label("Finish", systemImage: "checkmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

            case .paused:
                Button {
                    viewModel.resume()
                } label: {
                    Label("Resume", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    viewModel.finish()
                } label: {
                    Label("Finish", systemImage: "checkmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

            case .finished:
                Button {
                    dismiss()
                } label: {
                    Label("Done", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .tint(.teal)
        .controlSize(.large)
    }

    private func completionCard(result: StretchCompletionResult) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 52))
                .foregroundStyle(.green)

            Text("Break completed")
                .font(.title2.weight(.bold))

            HStack(spacing: 12) {
                completionMetric(title: "Earned", value: "+\(result.pointsAwarded)", symbol: "star.fill", tint: .yellow)
                completionMetric(title: "Today", value: "\(result.completedBreaksToday)", symbol: "figure.cooldown", tint: .teal)
                completionMetric(title: "Level", value: "\(result.level)", symbol: "trophy.fill", tint: .purple)
            }

            if !result.newlyUnlockedBadges.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("New badge")
                        .font(.headline)
                    ForEach(result.newlyUnlockedBadges) { badge in
                        Label(badge.title, systemImage: badge.symbolName)
                            .foregroundStyle(.teal)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }

            Button {
                dismiss()
            } label: {
                Label("Done", systemImage: "checkmark")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.teal)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func completionMetric(title: String, value: String, symbol: String, tint: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: symbol)
                .foregroundStyle(tint)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
