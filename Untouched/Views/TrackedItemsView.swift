import SwiftUI
import SwiftData

struct TrackedItemsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Counter.createdDate) private var counters: [Counter]

    var onSelect: ((Counter) -> Void)? = nil

    @State private var store = StoreService.shared
    @State private var showNameIt = false
    @State private var showPaywall = false
    @State private var counterPendingArchive: Counter? = nil
    @State private var summaryCounter: Counter? = nil

    private var activeCounters: [Counter] {
        counters.filter { !$0.isArchived }
    }

    private var pastCounters: [Counter] {
        counters
            .filter { $0.isArchived }
            .sorted { ($0.archivedDate ?? $0.createdDate) > ($1.archivedDate ?? $1.createdDate) }
    }

    private var activeLimit: Int {
        store.isPremiumUnlocked ? 3 : 1
    }

    private var canAddMore: Bool {
        activeCounters.count < activeLimit
    }

    var body: some View {
        ZStack {
            Color.utBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 22)
                    .padding(.top, 24)

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        activeSection
                        pastSection
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .presentationBackground(Color.utBackground)
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showNameIt) { NameItView() }
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .sheet(item: $summaryCounter) { counter in
            SummaryView(counter: counter)
        }
        .alert(
            Copy.Tracked.stopConfirmTitle,
            isPresented: archiveAlertBinding,
            presenting: counterPendingArchive
        ) { c in
            Button(Copy.Tracked.stopCancel, role: .cancel) { counterPendingArchive = nil }
            Button(Copy.Tracked.stopConfirm, role: .destructive) { archive(c) }
        } message: { c in
            Text(Copy.Tracked.stopConfirmBody(
                name: c.name,
                days: CounterEngine.daysUntouched(for: c),
                coins: c.earnedCoins.count
            ))
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(Copy.Tracked.title)
                    .font(.system(size: 28, weight: .medium))
                    .tracking(-0.8)
                    .foregroundStyle(Color.utTextPrimary)
                Text(Copy.Tracked.subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.utTextSecondary)
            }
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.utTextSecondary)
                    .frame(width: 32, height: 32)
                    .background(Color.utSurface, in: Circle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Sections

    private var activeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            LabelText(text: Copy.Tracked.activeLabel)

            if activeCounters.isEmpty {
                BentoCard {
                    Text(Copy.Tracked.activeEmpty)
                        .font(.utBody)
                        .foregroundStyle(Color.utTextSecondary)
                }
            } else {
                VStack(spacing: 10) {
                    ForEach(activeCounters) { counter in
                        activeCard(counter)
                    }
                }
            }

            PillButton(
                title: activeCounters.isEmpty ? Copy.Tracked.addFirst : Copy.Tracked.addAnother,
                style: activeCounters.isEmpty ? .primary : .ghost
            ) {
                tapAdd()
            }
            .padding(.top, 4)
        }
    }

    private var pastSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            LabelText(text: Copy.Tracked.pastLabel)

            if pastCounters.isEmpty {
                Text(Copy.Tracked.pastEmpty)
                    .font(.utBody)
                    .foregroundStyle(Color.utTextSecondary)
            } else {
                VStack(spacing: 10) {
                    ForEach(pastCounters) { counter in
                        pastCard(counter)
                    }
                }
            }
        }
    }

    // MARK: - Cards

    private func activeCard(_ counter: Counter) -> some View {
        let days = CounterEngine.daysUntouched(for: counter)
        let coins = counter.earnedCoins.count
        return BentoCard(padding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                Button {
                    HapticsService.selection()
                    onSelect?(counter)
                    dismiss()
                } label: {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .firstTextBaseline) {
                            HStack(spacing: 8) {
                                Circle().fill(Color.utAmber).frame(width: 6, height: 6)
                                Text(counter.name.uppercased())
                                    .font(.utBodyMedium)
                                    .foregroundStyle(Color.utTextPrimary)
                            }
                            Spacer()
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                Text("\(days)")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundStyle(Color.utTextPrimary)
                                    .monospacedDigit()
                                Text(Copy.Today.daysSuffix)
                                    .font(.utBody)
                                    .foregroundStyle(Color.utTextTertiary)
                            }
                        }

                        HStack {
                            Text("\(Copy.Today.since.uppercased()) \(formattedDate(counter.startDate).uppercased())")
                                .font(.utLabel)
                                .tracking(1.5)
                                .foregroundStyle(Color.utTextTertiary)
                            Spacer()
                            Text(Copy.Tracked.coinsKept(coins))
                                .font(.utLabel)
                                .tracking(1.5)
                                .foregroundStyle(Color.utTextTertiary)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Button {
                    HapticsService.selection()
                    counterPendingArchive = counter
                } label: {
                    Text(Copy.Tracked.stopCounting)
                        .font(.utBody)
                        .foregroundStyle(Color.utTextSecondary)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Capsule().strokeBorder(Color.utBorder, lineWidth: 0.5)
                        )
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func pastCard(_ counter: Counter) -> some View {
        let finalDays: Int = {
            if let archived = counter.archivedDate {
                return CounterEngine.daysUntouched(from: counter.startDate, to: archived)
            }
            return counter.allTimeLongest
        }()
        return Button {
            HapticsService.selection()
            summaryCounter = counter
        } label: {
            BentoCard(padding: 16) {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(counter.name.uppercased())
                                .font(.utBodyMedium)
                                .foregroundStyle(Color.utTextSecondary)
                            Spacer()
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                Text("\(finalDays)")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundStyle(Color.utTextSecondary)
                                    .monospacedDigit()
                                Text(Copy.Today.daysSuffix)
                                    .font(.utBody)
                                    .foregroundStyle(Color.utTextTertiary)
                            }
                        }
                        HStack {
                            if let archivedDate = counter.archivedDate {
                                Text(Copy.Tracked.stoppedOn(formattedDate(archivedDate).uppercased()))
                                    .font(.utLabel)
                                    .tracking(1.5)
                                    .foregroundStyle(Color.utTextTertiary)
                            }
                            Spacer()
                            Text(Copy.Tracked.coinsKept(counter.earnedCoins.count))
                                .font(.utLabel)
                                .tracking(1.5)
                                .foregroundStyle(Color.utTextTertiary)
                        }
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.utTextTertiary)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Derived

    private func formattedDate(_ date: Date) -> String {
        date.formatted(.dateTime.month(.abbreviated).day())
    }

    // MARK: - Actions

    private func tapAdd() {
        if canAddMore {
            showNameIt = true
        } else {
            showPaywall = true
        }
    }

    @MainActor
    private func archive(_ counter: Counter) {
        let days = CounterEngine.daysUntouched(for: counter)
        counter.allTimeLongest = max(counter.allTimeLongest, days)
        counter.isArchived = true
        counter.archivedDate = Date()
        HapticsService.selection()
        WidgetTimelineService.reloadAll()
        counterPendingArchive = nil
    }

    private var archiveAlertBinding: Binding<Bool> {
        Binding(
            get: { counterPendingArchive != nil },
            set: { if !$0 { counterPendingArchive = nil } }
        )
    }
}
