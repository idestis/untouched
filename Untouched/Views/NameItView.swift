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
            VStack(alignment: .leading, spacing: 14) {
                LabelText(text: Copy.NameIt.prompt)
                TextField(Copy.NameIt.placeholder, text: $name)
                    .font(.utNameDisplay)
                    .tracking(-1.5)
                    .foregroundStyle(Color.utTextPrimary)
                    .textInputAutocapitalization(.sentences)
                    .submitLabel(.done)
                privacyNote
            }

            VStack(alignment: .leading, spacing: 12) {
                LabelText(text: Copy.NameIt.startLabel)
                HStack(spacing: 10) {
                    startCard(
                        title: Copy.NameIt.startNow,
                        subtitle: Copy.NameIt.startNowSubtitle,
                        isSelected: startMode == .now
                    ) {
                        startMode = .now
                        HapticsService.selection()
                    }
                    startCard(
                        title: Copy.NameIt.startPast,
                        subtitle: Copy.NameIt.startPastSubtitle,
                        isSelected: startMode == .past
                    ) {
                        startMode = .past
                        HapticsService.selection()
                    }
                }

                if startMode == .past {
                    PastDatePicker(date: $pastDate)
                        .padding(.top, 6)
                }
            }

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

    private var privacyNote: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.utAmber)
                .frame(width: 6, height: 6)
            Text(Copy.NameIt.privacyNote)
                .font(.utBody)
                .foregroundStyle(Color.utTextSecondary)
        }
    }

    private func startCard(
        title: String,
        subtitle: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(isSelected ? Color.utBackground : Color.utTextPrimary)
                Text(subtitle)
                    .font(.utBody)
                    .foregroundStyle(isSelected ? Color.utBackground.opacity(0.55) : Color.utTextSecondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 92, alignment: .topLeading)
            .background(isSelected ? Color.utTextPrimary : Color.utSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(isSelected ? Color.clear : Color.utBorder, lineWidth: 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
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
