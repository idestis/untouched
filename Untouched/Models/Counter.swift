import Foundation
import SwiftData

@Model
final class Counter {
    @Attribute(.unique) var id: UUID
    var name: String
    var startDate: Date
    var createdDate: Date
    var allTimeLongest: Int
    var isArchived: Bool
    var archivedDate: Date?

    @Relationship(deleteRule: .cascade, inverse: \Reset.counter)
    var resets: [Reset] = []

    @Relationship(deleteRule: .cascade, inverse: \EarnedCoin.counter)
    var earnedCoins: [EarnedCoin] = []

    init(
        id: UUID = UUID(),
        name: String,
        startDate: Date,
        createdDate: Date = Date(),
        allTimeLongest: Int = 0,
        isArchived: Bool = false,
        archivedDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.createdDate = createdDate
        self.allTimeLongest = allTimeLongest
        self.isArchived = isArchived
        self.archivedDate = archivedDate
    }
}
