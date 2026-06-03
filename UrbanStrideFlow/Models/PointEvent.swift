import Foundation

enum PointEventKind: String, Codable {
    case stretchSession
    case stepGoal
    case stairs
}

struct PointEvent: Identifiable, Codable, Equatable {
    var id: UUID
    var date: Date
    var title: String
    var points: Int
    var kind: PointEventKind

    init(id: UUID = UUID(), date: Date = .now, title: String, points: Int, kind: PointEventKind) {
        self.id = id
        self.date = date
        self.title = title
        self.points = points
        self.kind = kind
    }
}
