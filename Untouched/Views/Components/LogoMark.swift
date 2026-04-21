import SwiftUI

struct LogoMark: View {
    var size: CGFloat = 56

    var body: some View {
        Image("LogoMark")
            .resizable()
            .renderingMode(.original)
            .interpolation(.high)
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

#Preview("Dark") {
    LogoMark()
        .padding(40)
        .background(Color.utBackground)
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    LogoMark()
        .padding(40)
        .background(Color.utBackground)
        .preferredColorScheme(.light)
}
