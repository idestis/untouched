import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
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
        .fullScreenCover(item: $pendingCoin, onDismiss: {
            Task { await checkForCoins() }
        }) { coin in
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
        let nextInfo = CounterEngine.nextMilestone(for: counter)
        let nextDays = nextInfo?.0.dayValue
        let nextRemaining = nextInfo?.daysRemaining
        let lastDays = Milestone.upTo(days: days).last?.dayValue ?? 0
        let totalCoinsTarget = Milestone.fixedCases.count + 1

        VStack(spacing: 0) {
            header(counter: counter)
                .padding(.bottom, 18)

            VStack(spacing: 22) {
                VStack(spacing: 6) {
                    LabelText(text: Copy.Today.daysLabel)
                    let mega = Font.utMegaCount(digits: String(days).count)
                    Text("\(days)")
                        .font(mega.font)
                        .tracking(mega.tracking)
                        .foregroundStyle(Color.utTextPrimary)
                        .monospacedDigit()
                        .animation(Motion.utDayRollover, value: days)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 10) {
                    MilestoneProgressBar(
                        progress: progress,
                        lastDays: lastDays > 0 ? lastDays : nil,
                        nextDays: nextDays
                    )
                    if let nextRemaining {
                        Text(Copy.Today.daysUntilNext(nextRemaining))
                            .font(.utBody)
                            .foregroundStyle(Color.utTextSecondary)
                    }
                }

                HStack(spacing: 12) {
                    bentoStat(
                        label: Copy.Today.coinsLabel,
                        value: "\(coinsEarned)",
                        suffix: Copy.Today.ofTotal(totalCoinsTarget)
                    )
                    bentoStat(
                        label: Copy.Today.longestLabel,
                        value: "\(longest)",
                        suffix: Copy.Today.daysSuffix
                    )
                }
            }

            Spacer(minLength: 0)

            GeometryReader { proxy in
                let spacing: CGFloat = 10
                let w = max(0, proxy.size.width - spacing)
                HStack(spacing: spacing) {
                    PillButton(title: Copy.Today.openShelf) { showShelf = true }
                        .frame(width: w * 0.65)
                    PillButton(title: Copy.Today.reset, style: .ghost) { showReset = true }
                        .frame(width: w * 0.35)
                }
            }
            .frame(height: 54)
        }
        .padding(.horizontal, 22)
        .padding(.top, 14)
        .padding(.bottom, 22)
    }

    private func header(counter: Counter) -> some View {
        HStack {
            Chip(text: counter.name, dotColor: Color.utAmber)
            Spacer()
            Chip(text: "\(Copy.Today.since) \(formattedStart(counter.startDate))")
                .contentShape(Rectangle())
            Button {
                HapticsService.selection()
                showSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.utTextSecondary)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.leading, 4)
        }
    }

    private func bentoStat(label: String, value: String, suffix: String) -> some View {
        BentoCard {
            VStack(alignment: .leading, spacing: 10) {
                LabelText(text: label)
                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text(value)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(Color.utTextPrimary)
                        .monospacedDigit()
                    Text(suffix)
                        .font(.utBody)
                        .foregroundStyle(Color.utTextTertiary)
                }
            }
        }
    }

    private func formattedStart(_ date: Date) -> String {
        date.formatted(.dateTime.month(.abbreviated).day())
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
        if profiles.first?.coinsBackupEnabled == true {
            CoinBackupService.shared.sync(counter)
        }
        pendingCoin = coin
    }
}
