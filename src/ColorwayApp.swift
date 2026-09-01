import SwiftUI

@main
struct MyApp: App {
    @NSApplicationDelegateAdaptor(ColorwayAppDelegate.self) private var appDelegate

    init() {
        ColorwayFontRegistration.register()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .nulWindowActivityAppearance()
        }
        .defaultSize(width: Nuul.Layout.windowWidth, height: Nuul.Layout.windowHeight)
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unified)
        .windowStyle(.hiddenTitleBar)
        .windowBackgroundDragBehavior(.enabled)
        .commands {
            ColorwayCommands()
        }

        Window("About Colorway", id: ColorwayWindowID.about) {
            ColorwayAboutView()
                .font(Nuul.Typography.body)
                .nulWindowActivityAppearance()
        }
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unifiedCompact)
        .windowStyle(.hiddenTitleBar)

        Window("Privacy Policy", id: ColorwayWindowID.privacyPolicy) {
            ColorwayPrivacyPolicyView()
                .font(Nuul.Typography.body)
                .nulWindowActivityAppearance()
        }
        .defaultSize(width: 540, height: 520)
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unifiedCompact)
        .windowStyle(.hiddenTitleBar)
    }
}
