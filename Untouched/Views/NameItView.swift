import SwiftUI
import SwiftData

struct NameItView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var startMode: StartMode = .now
    @State private var pastDate: Date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()

    enum StartMode: Hashable { case now, past }

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            LabelText(text: Copy.NameIt.prompt)

            TextField(Copy.NameIt.placeholder, text: $name)
                .font(.utNameDisplay)
                .tracking(-1.5)
                .foregroundStyle(Color.utTextPrimary)
                .textInputAutocapitalization(.sentences)
                .submitLabel(.done)

            Divider().background(Color.utBorder)

            VStack(alignment: .leading, spacing: 12) {
                LabelText(text: Copy.NameIt.startLabel)
                Picker("", selection: $startMode) {
                    Text(Copy.NameIt.startNow).tag(StartMode.now)
                    Text(Copy.NameIt.startPast).tag(StartMode.past)
                }
                .pickerStyle(.segmented)

                if startMode == .past {
                    DatePicker("", selection: $pastDate, in: ...Date(), displayedComponents: .date)
                        .labelsHidden()
                }
            }

            milestonesPreview

            Spacer()

            PillButton(title: Copy.NameIt.cta, isEnabled: isValid) {
                begin()
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color.utBackground.ignoresSafeArea())
    }

    private var milestonesPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            LabelText(text: Copy.NameIt.milestonesLabel)
            HStack(spacing: 8) {
                ForEach(Milestone.fixedCases, id: \.dayValue) { m in
                    Text("\(m.dayValue)")
                        .font(.utLabel)
                        .foregroundStyle(Color.utTextTertiary)
                        .tracking(1.5)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .overlay(Capsule().strokeBorder(Color.utBorder, lineWidth: 0.5))
                }
            }
        }
    }

    private var isValid: Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return (1...40).contains(trimmed.count)
    }

    private func begin() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let startDate: Date = startMode == .now ? Date() : pastDate
        let counter = Counter(name: trimmed, startDate: startDate)
        modelContext.insert(counter)
        HapticsService.selection()
        WidgetTimelineService.reloadAll()
        dismiss()
    }
}
