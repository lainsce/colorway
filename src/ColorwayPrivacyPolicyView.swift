import SwiftUI

struct ColorwayPrivacyPolicyView: View {
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Nuul.Spacing.xLarge) {
                    VStack(alignment: .leading, spacing: Nuul.Spacing.medium) {
                        Label("Your colors stay yours", systemImage: "lock.shield.fill")
                            .font(Nuul.Typography.viewTitle)

                        Text("Colorway is a local-first color picker. This policy explains what happens when you use the app.")
                            .font(Nuul.Typography.body)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: Nuul.Spacing.large) {
                        ColorwayPrivacyPolicySection(
                            title: "Color values stay local",
                            systemImage: "internaldrive",
                            text: "Colorway keeps the colors you enter, sample, and generate on this Mac. The app does not require an account or sync color data to a service."
                        )
                        ColorwayPrivacyPolicySection(
                            title: "Screen sampling",
                            systemImage: "eyedropper",
                            text: "When you choose Pick a color, Colorway uses macOS’s system color sampler. The sampled color is used locally to update the picker and is not uploaded."
                        )
                        ColorwayPrivacyPolicySection(
                            title: "Clipboard copies",
                            systemImage: "doc.on.clipboard",
                            text: "When you copy a HEX value or harmony swatch, Colorway places that value on the system clipboard so another app can receive it. macOS controls access to the clipboard."
                        )
                        ColorwayPrivacyPolicySection(
                            title: "No tracking or ads",
                            systemImage: "eye.slash",
                            text: "Colorway does not use advertising, analytics, tracking, third-party account services, or network requests."
                        )
                        ColorwayPrivacyPolicySection(
                            title: "Your choices",
                            systemImage: "checkmark.shield",
                            text: "You decide when to sample a color, copy a value, or reset the picker. You can clear copied values by replacing the clipboard contents with another app."
                        )
                    }
                }
                .padding(Nuul.Spacing.windowInset)
                .frame(maxWidth: 680, alignment: .leading)
                .background(
                    Nuul.itemSurface,
                    in: RoundedRectangle(cornerRadius: Nuul.Radius.surface, style: .continuous)
                )
            }
            .scrollEdgeEffectStyle(.soft, for: .top)
            .navigationTitle("Privacy Policy")
            .toolbar {
                ToolbarSpacer()

                ToolbarItem(placement: .primaryAction) {
                    Button("Done", systemImage: "xmark") {
                        dismissWindow(id: ColorwayWindowID.privacyPolicy)
                    }
                    .labelStyle(.iconOnly)
                    .font(.system(size: Nuul.Layout.toolbarGlyphSize, weight: .regular))
                    .frame(width: Nuul.Layout.toolbarControlSize)
                    .buttonStyle(.glass)
                }
            }
        }
        .frame(minWidth: 540, minHeight: 520)
        .background(Nuul.workspace.ignoresSafeArea(.all))
    }
}
