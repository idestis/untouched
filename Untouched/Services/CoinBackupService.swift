import Foundation
import SwiftData

/// Encrypted iCloud key-value backup for earned coins.
///
/// Opt-in. Each counter's coins (plus the minimum identity fields needed to
/// restore onto a clean device) are sealed with an iCloud-Keychain-synced
/// symmetric key and written to `NSUbiquitousKeyValueStore`. KVS payloads are
/// never visible in Files and sync automatically between devices on the same
/// Apple ID.
@MainActor
final class CoinBackupService {
    static let shared = CoinBackupService()

    private static let keyPrefix = "coin.v1."

    private let store = NSUbiquitousKeyValueStore.default

    var isAccountAvailable: Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }

    private init() {}

    // MARK: - Wire snapshot

    private struct CoinSnapshot: Codable, Equatable {
        let id: UUID
        let dayValue: Int
        let earnedDate: Date
        let runStartDate: Date
        let engraving: String?
    }

    private struct CounterBackup: Codable {
        let counterID: UUID
        let counterName: String
        let counterStartDate: Date
        let createdDate: Date
        let allTimeLongest: Int
        var coins: [CoinSnapshot]
        var updatedAt: Date
    }

    // MARK: - Push

    /// Overwrite the KVS entry for `counter` with its current coin set.
    func sync(_ counter: Counter) {
        let backup = makeBackup(for: counter)
        guard
            let json = try? JSONEncoder().encode(backup),
            let sealed = try? CryptoService.sealWithSyncedKey(json)
        else { return }
        store.set(sealed, forKey: key(for: counter.id))
        store.synchronize()
    }

    func syncAll(_ counters: [Counter]) {
        counters.forEach(sync)
    }

    func remove(counterID: UUID) {
        store.removeObject(forKey: key(for: counterID))
        store.synchronize()
    }

    // MARK: - Restore

    /// Pull every coin blob found in KVS and merge it into the local store.
    /// Matching is by counter id first, then (name + startDate) as a fallback.
    /// If no counter matches, a new one is created so the coins have a home.
    /// Returns the number of coins newly inserted.
    @discardableResult
    func restoreAll(into modelContext: ModelContext, counters: [Counter]) -> Int {
        store.synchronize()
        let all = store.dictionaryRepresentation
        var inserted = 0

        for (k, value) in all where k.hasPrefix(Self.keyPrefix) {
            guard
                let sealed = value as? Data,
                let plaintext = try? CryptoService.openWithSyncedKey(sealed),
                let backup = try? JSONDecoder().decode(CounterBackup.self, from: plaintext)
            else { continue }

            let counter = resolveCounter(for: backup, in: counters, modelContext: modelContext)
            if backup.allTimeLongest > counter.allTimeLongest {
                counter.allTimeLongest = backup.allTimeLongest
            }
            let existingIDs = Set(counter.earnedCoins.map(\.id))
            for snap in backup.coins where !existingIDs.contains(snap.id) {
                let coin = EarnedCoin(
                    id: snap.id,
                    dayValue: snap.dayValue,
                    earnedDate: snap.earnedDate,
                    runStartDate: snap.runStartDate,
                    engraving: snap.engraving
                )
                modelContext.insert(coin)
                coin.counter = counter
                counter.earnedCoins.append(coin)
                inserted += 1
            }
        }

        try? modelContext.save()
        return inserted
    }

    // MARK: - Internals

    private func key(for id: UUID) -> String { "\(Self.keyPrefix)\(id.uuidString)" }

    private func makeBackup(for counter: Counter) -> CounterBackup {
        let snaps = counter.earnedCoins.map {
            CoinSnapshot(
                id: $0.id,
                dayValue: $0.dayValue,
                earnedDate: $0.earnedDate,
                runStartDate: $0.runStartDate,
                engraving: $0.engraving
            )
        }
        return CounterBackup(
            counterID: counter.id,
            counterName: counter.name,
            counterStartDate: counter.startDate,
            createdDate: counter.createdDate,
            allTimeLongest: counter.allTimeLongest,
            coins: snaps,
            updatedAt: Date()
        )
    }

    private func resolveCounter(
        for backup: CounterBackup,
        in counters: [Counter],
        modelContext: ModelContext
    ) -> Counter {
        if let byID = counters.first(where: { $0.id == backup.counterID }) { return byID }
        if let byNameAndStart = counters.first(where: {
            $0.name == backup.counterName
            && Calendar.current.isDate($0.startDate, inSameDayAs: backup.counterStartDate)
        }) { return byNameAndStart }

        let made = Counter(
            id: backup.counterID,
            name: backup.counterName,
            startDate: backup.counterStartDate,
            createdDate: backup.createdDate,
            allTimeLongest: backup.allTimeLongest
        )
        modelContext.insert(made)
        return made
    }
}
