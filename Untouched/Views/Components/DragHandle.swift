import SwiftUI

struct DragHandle: View {
    var body: some View {
        Capsule()
            .fill(Color.utTextTertiary.opacity(0.5))
            .frame(width: 40, height: 5)
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            .padding(.bottom, 6)
            .accessibilityHidden(true)
    }
}
