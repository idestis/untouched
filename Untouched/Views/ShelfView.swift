import SwiftUI
import SwiftData

struct ShelfView: View {
    @Environment(\.dismiss) private var dismiss
    let counter: Counter

    @State private var selectedCoin: EarnedCoin?
    @State private var showPreviousRuns = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    private let lockedPreviewCount = 3

    var body: some View {
        ZStack {
            Color.utBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    coinsGrid
                    if pastHorizon { keepGoingCard }
                    previousRunsCard
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .presentationBackground(Color.utBackground)
        .presentationDragIndicator(.visible)
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
        let totalTarget = Milestone.shelfHorizon.count
        let ahead = max(0, totalTarget - earned)
        return VStack(alignment: .leading, spacing: 8) {
            LabelText(text: Copy.Shelf.title)
            Text(displayName)
                .font(.utScreenTitle)
                .tracking(-1)
                .foregroundStyle(Color.utTextPrimary)
            Text(Copy.Shelf.summary(earned: earned, ahead: ahead))
                .font(.utBody)
                .foregroundStyle(Color.utTextSecondary)
        }
    }

    private var displayName: String {
        let name = counter.name.trimmingCharacters(in: .whitespaces)
        guard let last = name.last else { return name }
        if [".", "!", "?"].contains(String(last)) { return name }
        return name + "."
    }

    // MARK: - Coin grid

    private var coinsGrid: some View {
        let earnedCoins = counter.earnedCoins.sorted(by: { $0.dayValue < $1.dayValue })
        let earnedValues = Set(earnedCoins.map(\.dayValue))
        let lockedToShow = Milestone.shelfHorizon
            .filter { !earnedValues.contains($0.dayValue) }
            .prefix(lockedPreviewCount)
        let nextLockedDay = lockedToShow.first?.dayValue

        return LazyVGrid(columns: columns, spacing: 22) {
            ForEach(earnedCoins, id: \.id) { coin in
                earnedCell(coin: coin)
            }
            ForEach(Array(lockedToShow), id: \.dayValue) { milestone in
                lockedCell(milestone: milestone, isNext: milestone.dayValue == nextLockedDay)
            }
        }
    }

    private var pastHorizon: Bool {
        let earnedValues = Set(counter.earnedCoins.map(\.dayValue))
        return Milestone.shelfHorizon.allSatisfy { earnedValues.contains($0.dayValue) }
    }

    private var keepGoingCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            LabelText(text: Copy.Shelf.keepGoingLabel, color: Color.utAmber)
            Text(Copy.Shelf.keepGoingBody)
                .font(.utBody)
                .foregroundStyle(Color.utTextSecondary)
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

    private func lockedCell(milestone: Milestone, isNext: Bool) -> some View {
        VStack(spacing: 10) {
            CoinRing(value: milestone.dayValue, earned: false, size: .medium, labelStyle: .milestone)
            Group {
                if isNext {
                    let remaining = CounterEngine.daysUntouched(
                        from: Date(),
                        to: milestone.targetDate(from: counter.startDate)
                    )
                    Text(Copy.Shelf.toGo(remaining).uppercased())
                } else {
                    Text(Copy.Shelf.dashPlaceholder)
                }
            }
            .font(.utLabel)
            .tracking(1.5)
            .foregroundStyle(Color.utTextTertiary)
        }
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
                    Text(previousRunsSummary)
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

    private var previousRunsSummary: String {
        if counter.resets.isEmpty {
            return Copy.Shelf.previousRunsEmpty
        }
        return Copy.Shelf.resetsSummary(
            attempts: counter.resets.count,
            longestDays: counter.allTimeLongest
        )
    }
}
