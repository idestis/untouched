import SwiftUI

struct Chip: View {
    let text: String
    var dotColor: Color? = nil

    var body: some View {
        HStack(spacing: 6) {
            if let dotColor {
                Circle().fill(dotColor).frame(width: 5, height: 5)
            }
            Text(text)
                .font(.utChip)
                .foregroundStyle(Color.utTextSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .overlay(
            Capsule().strokeBorder(Color.utBorder, lineWidth: 0.5)
        )
    }
}
