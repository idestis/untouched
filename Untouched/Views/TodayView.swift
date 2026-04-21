import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Counter> { !$0.isArchived }, sort: \Counter.createdDate)
    private var activeCounters: [Counter]

    @State private var showSettings = false
    @State private var showShelf = false
    @State private var showReset = false
    @State private var showCoinEarned = false
    @State private var pendingCoin: EarnedCoin? = nil

    private var counter: Counter? { activeCounters.first }

    var body: some View {
        ZStack {
            Color.utBackground.ignoresSafeArea()

            if let counter {
                content(for: counter)
            } else {
                NameItView()
            }
        }
        .sheet(isPresented: $showSettings) { SettingsSheet() }
        .sheet(isPresented: $showShelf) {
            if let counter { ShelfView(counter: counter) }
        }
        .fullScreenCover(isPresented: $showReset) {
            if let counter { ResetView(counter: counter) }
        }
        .fullScreenCover(item: $pendingCoin) { coin in
            CoinEarnedView(coin: coin)
        }
        .task(id: counter?.id) {
            await checkForCoins()
        }
    }

    // MARK: - Layout

    @ViewBuilder
    private func content(for counter: Counter) -> some View {
        let days = CounterEngine.daysUntouched(for: counter)
        let coinsEarned = counter.earnedCoins.count
        let longest = max(counter.allTimeLongest, days)
        let progress = CounterEngine.progressToNextMilestone(for: counter)
        let next = CounterEngine.nextMilestone(for: counter)

        VStack(alignment: .leading, spacing: 0) {
            header
            Spacer(minLength: 16)

            Chip(text: counter.name)
                .padding(.bottom, 8)

            Text("\(days)")
                .font(.utMega)
                .tracking(-6)
                .foregroundStyle(Color.utTextPrimary)
                .monospacedDigit()
                .animation(Motion.utDayRollover, value: days)

            LabelText(text: Copy.Today.daysLabel)
                .padding(.top, 4)

            MilestoneProgressBar(
                progress: progress,
                leadingLabel: progress > 0 ? "\(days)d" : nil,
                trailingLabel: next.map { "\($0.0.dayValue)d" }
            )
            .padding(.top, 28)
            .padding(.bottom, 28)

            HStack(spacing: 12) {
                bentoStat(label: Copy.Today.coinsLabel, value: "\(coinsEarned)")
                bentoStat(label: Copy.Today.longestLabel, value: "\(longest)")
            }

            Spacer()

            VStack(spacing: 10) {
                PillButton(title: Copy.Today.openShelf) { showShelf = true }
                PillButton(title: Copy.Today.reset, style: .ghost) { showReset = true }
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 22)
    }

    private var header: some View {
        HStack {
            LabelText(text: Copy.Widget.brand)
            Spacer()
            Button { showSettings = true } label: {
                Image(systemName: "gearshape")
                    .foregroundStyle(Color.utTextSecondary)
            }
        }
    }

    private func bentoStat(label: String, value: String) -> some View {
        BentoCard {
            VStack(alignment: .leading, spacing: 8) {
                LabelText(text: label)
                Text(value)
                    .font(.utBodyMedium)
                    .foregroundStyle(Color.utTextPrimary)
            }
        }
    }

    // MARK: - Logic

    @MainActor
    private func checkForCoins() async {
        guard let counter else { return }
        let unearned = CounterEngine.unearnedMilestones(for: counter)
        guard let next = unearned.first else { return }

        let coin = EarnedCoin(
            dayValue: next.dayValue,
            earnedDate: Date(),
            runStartDate: counter.startDate
        )
        counter.earnedCoins.append(coin)
        modelContext.insert(coin)
        coin.counter = counter

        HapticsService.coinEarned()
        WidgetTimelineService.reloadAll()
        pendingCoin = coin
    }
}
