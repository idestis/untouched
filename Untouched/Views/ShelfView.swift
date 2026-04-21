import SwiftUI
import SwiftData

struct ShelfView: View {
    @Environment(\.dismiss) private var dismiss
    let counter: Counter

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    earned
                    locked
                    previousRuns
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 22)
            }
            .background(Color.utBackground.ignoresSafeArea())
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color.utTextSecondary)
                }
            }
        }
    }

    private var earned: some View {
        VStack(alignment: .leading, spacing: 16) {
            LabelText(text: Copy.Shelf.earnedLabel)
            if counter.earnedCoins.isEmpty {
                Text("No coins yet. The first comes at day one.")
                    .font(.utBody)
                    .foregroundStyle(Color.utTextSecondary)
            } else {
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(counter.earnedCoins.sorted(by: { $0.dayValue < $1.dayValue }), id: \.id) { coin in
                        CoinRing(value: coin.dayValue, earned: true, size: .medium, glow: false)
                    }
                }
            }
        }
    }

    private var locked: some View {
        let days = CounterEngine.daysUntouched(for: counter)
        let earnedValues = Set(counter.earnedCoins.map(\.dayValue))
        let all = Milestone.upTo(days: days * 0 + 365 * 3) // show a few upcoming years
        let lockedList = all.filter { !earnedValues.contains($0.dayValue) }

        return VStack(alignment: .leading, spacing: 16) {
            LabelText(text: Copy.Shelf.lockedLabel)
            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(lockedList, id: \.dayValue) { m in
                    CoinRing(value: m.dayValue, earned: false, size: .medium)
                }
            }
        }
    }

    private var previousRuns: some View {
        VStack(alignment: .leading, spacing: 12) {
            LabelText(text: Copy.Shelf.previousRunsLabel)
            BentoCard {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Longest")
                            .font(.utBody)
                            .foregroundStyle(Color.utTextSecondary)
                        Spacer()
                        Text("\(counter.allTimeLongest) days")
                            .font(.utBodyMedium)
                            .foregroundStyle(Color.utTextPrimary)
                    }
                    HStack {
                        Text("Resets")
                            .font(.utBody)
                            .foregroundStyle(Color.utTextSecondary)
                        Spacer()
                        Text("\(counter.resets.count)")
                            .font(.utBodyMedium)
                            .foregroundStyle(Color.utTextPrimary)
                    }
                }
            }
        }
    }
}
