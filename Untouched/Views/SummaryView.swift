import SwiftUI
import SwiftData

struct SummaryView: View {
    @Environment(\.dismiss) private var dismiss
    let counter: Counter

    @State private var selectedCoin: EarnedCoin?
    @State private var showPreviousRuns = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    private var finalDays: Int {
        if let archived = counter.archivedDate {
            return CounterEngine.daysUntouched(from: counter.startDate, to: archived)
        }
        return counter.allTimeLongest
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.utBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    header
                    coinsGrid
                    if !counter.resets.isEmpty { previousRunsCard }
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)
                .padding(.bottom, 80)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button(action: { dismiss() }) {
                Text(Copy.Summary.close)
                    .font(.utBody)
                    .foregroundStyle(Color.utTextSecondary)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 20)
        }
        .sheet(item: $selectedCoin) { coin in
            CoinDetailView(coin: coin)
        }
        .sheet(isPresented: $showPreviousRuns) {
            PreviousRunsView(counter: counter)
        }
    }

    // MARK: - Header

    private var header: some View {
        let earned = counter.earnedCoins.count
        return VStack(alignment: .leading, spacing: 10) {
            LabelText(text: Copy.Summary.stoppedLabel)
            Text(displayName)
                .font(.utScreenTitle)
                .tracking(-1)
                .foregroundStyle(Color.utTextPrimary)
            Text(Copy.Summary.line(days: finalDays, coins: earned))
                .font(.utBody)
                .foregroundStyle(Color.utTextSecondary)
            Text(dateRange)
                .font(.utLabel)
                .tracking(1.5)
                .foregroundStyle(Color.utTextTertiary)
                .padding(.top, 4)
        }
    }

    private var displayName: String {
        let name = counter.name.trimmingCharacters(in: .whitespaces)
        guard let last = name.last else { return name }
        if [".", "!", "?"].contains(String(last)) { return name }
        return name + "."
    }

    private var dateRange: String {
        let start = counter.startDate.formatted(.dateTime.month(.abbreviated).day()).uppercased()
        let end = (counter.archivedDate ?? Date())
            .formatted(.dateTime.month(.abbreviated).day())
            .uppercased()
        return Copy.Summary.range(from: start, to: end)
    }

    // MARK: - Coins

    private var coinsGrid: some View {
        let earnedCoins = counter.earnedCoins.sorted(by: { $0.dayValue < $1.dayValue })
        return VStack(alignment: .leading, spacing: 14) {
            LabelText(text: Copy.Summary.coinsKeptLabel)

            if earnedCoins.isEmpty {
                Text(Copy.Summary.coinsEmpty)
                    .font(.utBody)
                    .foregroundStyle(Color.utTextSecondary)
            } else {
                LazyVGrid(columns: columns, spacing: 22) {
                    ForEach(earnedCoins, id: \.id) { coin in
                        earnedCell(coin: coin)
                    }
                }
            }
        }
    }

    private func earnedCell(coin: EarnedCoin) -> some View {
        Button {
            HapticsService.selection()
            selectedCoin = coin
        } label: {
            VStack(spacing: 10) {
                CoinRing(value: coin.dayValue, earned: true, size: .medium, glow: false, labelStyle: .milestone)
                Text(coin.earnedDate.formatted(.dateTime.month(.abbreviated).day()).uppercased())
                    .font(.utLabel)
                    .tracking(1.5)
                    .foregroundStyle(Color.utTextTertiary)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Previous runs

    private var previousRunsCard: some View {
        Button {
            HapticsService.selection()
            showPreviousRuns = true
        } label: {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    LabelText(text: Copy.Shelf.previousRunsLabel)
                    Text(Copy.Shelf.resetsSummary(
                        attempts: counter.resets.count,
                        longestDays: counter.allTimeLongest
                    ))
                    .font(.utBody)
                    .foregroundStyle(Color.utTextPrimary)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.utTextTertiary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.utSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.utBorder, lineWidth: 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
