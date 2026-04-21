import SwiftUI
import SwiftData

struct ManifestoView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: 32)

            LabelText(text: Copy.Manifesto.label)
                .padding(.bottom, 24)

            Text(Copy.Manifesto.title)
                .font(.utH1)
                .foregroundStyle(Color.utTextPrimary)
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

    private func completeOnboarding() {
        let profile = profiles.first ?? {
            let p = UserProfile(hasCompletedOnboarding: true)
            modelContext.insert(p)
            return p
        }()
        profile.hasCompletedOnboarding = true
    }
}
