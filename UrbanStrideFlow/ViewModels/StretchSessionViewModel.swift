import Foundation
import Combine

@MainActor
final class StretchSessionViewModel: ObservableObject {
    struct Exercise: Identifiable {
        let id = UUID()
        let name: String
        let instruction: String
        let symbolName: String
    }

    enum SessionState {
        case ready
        case running
        case paused
        case finished
    }

    @Published private(set) var remainingSeconds = 180
    @Published private(set) var state: SessionState = .ready

    let exercises = [
        Exercise(name: "Neck stretch", instruction: "Slowly tilt your head side to side. Keep shoulders relaxed.", symbolName: "figure.mind.and.body"),
        Exercise(name: "Shoulder rolls", instruction: "Roll shoulders forward, then backward with easy breathing.", symbolName: "arrow.triangle.2.circlepath"),
        Exercise(name: "Side bends", instruction: "Reach one arm overhead and lean gently to each side.", symbolName: "figure.flexibility"),
        Exercise(name: "Wrist stretch", instruction: "Extend each arm and gently stretch through the wrist.", symbolName: "hand.raised.fill"),
        Exercise(name: "Stand and walk", instruction: "Stand up, walk around, and reset your posture.", symbolName: "figure.walk")
    ]

    private var timerTask: Task<Void, Never>?

    var currentExercise: Exercise {
        let elapsed = 180 - remainingSeconds
        let index = min(exercises.count - 1, elapsed / 36)
        return exercises[index]
    }

    var completedExerciseNames: [String] {
        exercises.map(\.name)
    }

    var elapsedSeconds: Int {
        180 - remainingSeconds
    }

    var formattedRemainingTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var progress: Double {
        1 - Double(remainingSeconds) / 180
    }

    func start() {
        remainingSeconds = 180
        state = .running
        runTimer()
    }

    func pause() {
        guard state == .running else { return }
        state = .paused
        timerTask?.cancel()
    }

    func resume() {
        guard state == .paused else { return }
        state = .running
        runTimer()
    }

    func finish() {
        timerTask?.cancel()
        remainingSeconds = 0
        state = .finished
    }

    private func runTimer() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self, !Task.isCancelled else { return }

                if self.remainingSeconds > 1 {
                    self.remainingSeconds -= 1
                } else {
                    self.finish()
                    return
                }
            }
        }
    }
}
