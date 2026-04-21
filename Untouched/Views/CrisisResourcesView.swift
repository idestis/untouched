import SwiftUI

struct CrisisResourcesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(Copy.CrisisResources.intro)
                        .font(.utBody)
                        .foregroundStyle(Color.utTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    resourceRow(name: Copy.CrisisResources.samhsaName, number: Copy.CrisisResources.samhsaNumber)
                    resourceRow(name: Copy.CrisisResources.suicideLineName, number: Copy.CrisisResources.suicideLineNumber)
                    resourceRow(name: Copy.CrisisResources.samaritansName, number: Copy.CrisisResources.samaritansNumber)
                }
                .padding(22)
            }
            .background(Color.utBackground.ignoresSafeArea())
            .navigationTitle(Copy.CrisisResources.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func resourceRow(name: String, number: String) -> some View {
        BentoCard(padding: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(.utBodyMedium)
                    .foregroundStyle(Color.utTextPrimary)
                Text(number)
                    .font(.utBody)
                    .foregroundStyle(Color.utAmber)
            }
        }
    }
}
