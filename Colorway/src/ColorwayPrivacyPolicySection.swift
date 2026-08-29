import SwiftUI

struct ColorwayPrivacyPolicySection: View {
    let title: LocalizedStringResource
    let systemImage: String
    let text: LocalizedStringResource

    var body: some View {
        VStack(alignment: .leading, spacing: Nuul.Spacing.medium) {
            Label(title, systemImage: systemImage)
                .font(Nuul.Typography.contentBlockTitle)

            Text(text)
                .font(Nuul.Typography.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
