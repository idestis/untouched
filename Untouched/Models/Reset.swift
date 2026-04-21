import Foundation
import SwiftData

@Model
final class Reset {
    @Attribute(.unique) var id: UUID
    var date: Date
    /// Sealed bytes from `CryptoService.seal(_:)`. Plaintext never touches disk.
    var confessionSealed: Data
    var runLengthDays: Int

    var counter: Counter?

    init(
        id: UUID = UUID(),
        date: Date,
        confessionSealed: Data,
        runLengthDays: Int
    ) {
        self.id = id
        self.date = date
        self.confessionSealed = confessionSealed
        self.runLengthDays = runLengthDays
    }
}
