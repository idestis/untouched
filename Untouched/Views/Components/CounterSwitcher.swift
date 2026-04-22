import SwiftUI

/// Inline segmented switcher for active counters. Sized to content,
/// left-aligned. Tapping a segment switches to that counter; the trailing
/// switch icon opens the tracked-items manager. Capsule grows horizontally
/// as more counters are added.
struct CounterSwitcher: View {
    let counters: [Counter]
    @Binding var selectedID: UUID?
    var onManage: () -> Void

    var body: some View {
        HStack(spacing: 2) {
            ForEach(counters) { counter in
                segment(counter: counter, isSelected: counter.id == selectedID)
            }
            trailing
        }
        .padding(3)
        .background(Color.utSurface, in: Capsule())
        .overlay(
            Capsule().strokeBorder(Color.utBorder, lineWidth: 0.5)
        )
        .fixedSize(horizontal: true, vertical: false)
    }

    private func segment(counter: Counter, isSelected: Bool) -> some View {
        Button {
            guard !isSelected else { return }
            HapticsService.selection()
            withAnimation(.easeInOut(duration: 0.18)) {
                selectedID = counter.id
            }
        } label: {
            HStack(spacing: 6) {
                if isSelected {
                    Circle()
                        .fill(Color.utAmber)
                        .frame(width: 5, height: 5)
                        .transition(.opacity)
                }
                Text(counter.name.uppercased())
                    .font(.utChip)
                    .tracking(0.5)
                    .foregroundStyle(isSelected ? Color.utTextPrimary : Color.utTextTertiary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                Capsule().fill(isSelected ? Color.utBackground : Color.clear)
            )
            .overlay(
                Capsule().strokeBorder(
                    isSelected ? Color.utBorder : Color.clear,
                    lineWidth: 0.5
                )
            )
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var trailing: some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(Color.utBorder)
                .frame(width: 0.5, height: 14)
            Button {
                HapticsService.selection()
                onManage()
            } label: {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.utTextTertiary)
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 4)
        .padding(.trailing, 6)
    }
}
