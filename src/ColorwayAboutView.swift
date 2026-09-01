#if os(macOS)
import AppKit
import SwiftUI

struct ColorwayAboutView: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        ZStack {
            Nuul.workspace
                .ignoresSafeArea()

            VStack(spacing: Nuul.Spacing.large) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: 128, height: 128)

                VStack(spacing: Nuul.Spacing.medium) {
                    Text("Colorway")
                        .font(Nuul.Typography.display)

                    Text("Pick colors. Explore harmony.")
                        .font(Nuul.Typography.viewSubtitle)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Text("Pick a color, explore harmonies, and copy exact values.")
                    .font(Nuul.Typography.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .lineLimit(2...2)
                    .frame(width: 310)

                VStack(spacing: Nuul.Spacing.small) {
                    Text("Version \(versionString)")
                        .font(Nuul.Typography.technicalCaption)
                        .foregroundStyle(.secondary)

                    Text("Made with SwiftUI for Mac.")
                        .font(Nuul.Typography.caption)
                        .foregroundStyle(.tertiary)
                }

                Button("Privacy Policy") {
                    openWindow(id: ColorwayWindowID.privacyPolicy)
                }
                .buttonStyle(NuulButtonStyle(kind: .quiet))
            }
            .padding(Nuul.Spacing.xLarge)
        }
        .frame(width: 400)
        .ignoresSafeArea(.all)
    }

    private var versionString: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
            ?? "1"
        return "\(version) (\(build))"
    }
}
#endif
