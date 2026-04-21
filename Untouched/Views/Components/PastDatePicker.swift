import SwiftUI

struct PastDatePicker: View {
    @Binding var date: Date
    @State private var editing: Field?

    enum Field: Identifiable, Hashable {
        case day, month, year
        var id: Self { self }
    }

    private let calendar = Calendar.current

    var body: some View {
        HStack(spacing: 10) {
            fieldButton(
                field: .day,
                title: Copy.NameIt.dayLabel,
                value: "\(day)"
            )
            fieldButton(
                field: .month,
                title: Copy.NameIt.monthLabel,
                value: calendar.shortMonthSymbols[month - 1]
            )
            fieldButton(
                field: .year,
                title: Copy.NameIt.yearLabel,
                value: "\(year)"
            )
        }
        .sheet(item: $editing) { field in
            sheet(for: field)
        }
        .onChange(of: date) { _, _ in clampToToday() }
    }

    private func clampToToday() {
        if date > Date() {
            date = Date()
        }
    }

    private func fieldButton(field: Field, title: String, value: String) -> some View {
        Button {
            HapticsService.selection()
            editing = field
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(.utLabel)
                    .tracking(2)
                    .foregroundStyle(Color.utTextTertiary)
                Text(value)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.utTextPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.utSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.utBorder, lineWidth: 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func sheet(for field: Field) -> some View {
        let content: PickerSheetContent = {
            switch field {
            case .day:
                return PickerSheetContent(
                    title: Copy.NameIt.dayLabel,
                    selection: dayBinding,
                    options: dayRange.map { ($0, "\($0)") }
                )
            case .month:
                return PickerSheetContent(
                    title: Copy.NameIt.monthLabel,
                    selection: monthBinding,
                    options: monthRange.map { ($0, calendar.monthSymbols[$0 - 1]) }
                )
            case .year:
                return PickerSheetContent(
                    title: Copy.NameIt.yearLabel,
                    selection: yearBinding,
                    options: yearRange.map { ($0, "\($0)") }
                )
            }
        }()

        PickerSheet(content: content, onDone: { editing = nil })
            .presentationDetents([.height(320)])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color.utBackground)
    }

    private var components: DateComponents {
        calendar.dateComponents([.day, .month, .year], from: date)
    }
    private var day: Int { components.day ?? 1 }
    private var month: Int { components.month ?? 1 }
    private var year: Int { components.year ?? calendar.component(.year, from: Date()) }

    private var dayRange: [Int] {
        let range = calendar.range(of: .day, in: .month, for: date) ?? 1..<29
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        if year == todayComponents.year, month == todayComponents.month, let today = todayComponents.day {
            return Array(range.lowerBound...min(today, range.upperBound - 1))
        }
        return Array(range)
    }

    private var monthRange: [Int] {
        let currentYear = calendar.component(.year, from: Date())
        let currentMonth = calendar.component(.month, from: Date())
        if year == currentYear {
            return Array(1...currentMonth)
        }
        return Array(1...12)
    }

    private var yearRange: [Int] {
        let now = calendar.component(.year, from: Date())
        return Array((now - 20)...now)
    }

    private var dayBinding: Binding<Int> {
        Binding(
            get: { day },
            set: { newDay in
                var c = components
                c.day = newDay
                commit(c)
            }
        )
    }

    private var monthBinding: Binding<Int> {
        Binding(
            get: { month },
            set: { newMonth in
                var c = components
                c.month = newMonth
                c.day = clampedDay(day, inMonth: newMonth, year: year)
                commit(c)
            }
        )
    }

    private var yearBinding: Binding<Int> {
        Binding(
            get: { year },
            set: { newYear in
                var c = components
                c.year = newYear
                c.day = clampedDay(day, inMonth: month, year: newYear)
                commit(c)
            }
        )
    }

    private func clampedDay(_ day: Int, inMonth month: Int, year: Int) -> Int {
        var probe = DateComponents()
        probe.day = 1
        probe.month = month
        probe.year = year
        guard let firstOfMonth = calendar.date(from: probe),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth) else {
            return day
        }
        return min(day, range.upperBound - 1)
    }

    private func commit(_ c: DateComponents) {
        guard let candidate = calendar.date(from: c) else { return }
        date = min(candidate, Date())
    }
}

private struct PickerSheetContent {
    let title: String
    let selection: Binding<Int>
    let options: [(Int, String)]
}

private struct PickerSheet: View {
    let content: PickerSheetContent
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text(content.title.uppercased())
                    .font(.utLabel)
                    .tracking(2)
                    .foregroundStyle(Color.utTextTertiary)
                HStack {
                    Spacer()
                    Button(action: onDone) {
                        Text("Done")
                            .font(.utBodyMedium)
                            .foregroundStyle(Color.utAmber)
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 20)
            .padding(.bottom, 4)

            Picker("", selection: content.selection) {
                ForEach(content.options, id: \.0) { option in
                    Text(option.1)
                        .foregroundStyle(Color.utTextPrimary)
                        .tag(option.0)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
