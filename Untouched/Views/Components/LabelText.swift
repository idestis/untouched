import SwiftUI

struct LabelText: View {
    let text: String
    var color: Color = .utTextTertiary

    var body: some View {
        Text(text.uppercased())
            .font(.utLabel)
            .tracking(2)
            .foregroundStyle(color)
    }
}
