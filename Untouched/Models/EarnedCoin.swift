import Foundation
import SwiftData

@Model
final class EarnedCoin {
    @Attribute(.unique) var id: UUID
    /// Source of truth for the milestone. Always matches `Milestone.dayValue`.
    var dayValue: Int
    var earnedDate: Date
    var runStartDate: Date
    var engraving: String?

    var counter: Counter?

    init(
        id: UUID = UUID(),
        dayValue: Int,
        earnedDate: Date,
        runStartDate: Date,
        engraving: String? = nil
    ) {
        self.id = id
        self.dayValue = dayValue
        self.earnedDate = earnedDate
        self.runStartDate = runStartDate
        self.engraving = engraving
    }

    var milestone: Milestone? { Milestone(dayValue: dayValue) }
}
