import SwiftUI
import SwiftData

struct ManifestoView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            LogoMark(size: 44)
                .padding(.leading, -4)
                .padding(.top, 4)
                .padding(.bottom, 8)

            LabelText(text: Copy.Manifesto.label)
                .padding(.bottom, 28)

            titleText
                .font(.utH1)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Text(Copy.Manifesto.body)
                .font(.utBody)
                .foregroundStyle(Color.utTextSecondary)
                .padding(.top, 24)
                .lineSpacing(4)

            Spacer()

            PillButton(title: Copy.Manifesto.cta) {
                completeOnboarding()
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color.utBackground.ignoresSafeArea())
    }

    private var titleText: Text {
        Text(Copy.Manifesto.titleLine1 + "\n")
            .foregroundColor(Color.utTextPrimary)
        + Text(Copy.Manifesto.titleLine2 + "\n")
            .foregroundColor(Color.utTextPrimary)
        + Text(Copy.Manifesto.titleLine3)
            .foregroundColor(Color.utTextTertiary)
    }

    private func completeOnboarding() {
        let profile = profiles.first ?? {
            let p = UserProfile(hasCompletedOnboarding: true)
            modelContext.insert(p)
            return p
        }()
        profile.hasCompletedOnboarding = true
    }
}
