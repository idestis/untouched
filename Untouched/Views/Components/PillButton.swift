import SwiftUI

struct PillButton: View {
    enum Style { case primary, ghost, danger }

    let title: String
    var style: Style = .primary
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticsService.selection()
            action()
        }) {
            Text(title)
                .font(.utBodyMedium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, style == .primary ? 16 : 12)
                .foregroundStyle(foreground)
                .background(background)
                .clipShape(Capsule())
                .overlay(
                    Capsule().strokeBorder(borderColor, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.4)
    }

    private var foreground: Color {
        switch style {
        case .primary: return .utBackground
        case .ghost:   return .utTextSecondary
        case .danger:  return .utDanger
        }
    }

    private var background: Color {
        switch style {
        case .primary: return .utTextPrimary
        case .ghost:   return .clear
        case .danger:  return .clear
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary: return .clear
        case .ghost:   return .utBorder
        case .danger:  return .utDanger.opacity(0.5)
        }
    }
}
