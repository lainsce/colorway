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
        }
        .defaultSize(width: Nuul.Layout.windowWidth, height: Nuul.Layout.windowHeight)
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unifiedCompact)
        .windowStyle(.hiddenTitleBar)
        .windowBackgroundDragBehavior(.enabled)
        .commands {
            ColorwayCommands()
        }

        Window("About Colorway", id: ColorwayWindowID.about) {
            ColorwayAboutView()
                .font(Nuul.Typography.body)
        }
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unifiedCompact)
        .windowStyle(.hiddenTitleBar)

        Window("Privacy Policy", id: ColorwayWindowID.privacyPolicy) {
            ColorwayPrivacyPolicyView()
                .font(Nuul.Typography.body)
        }
        .defaultSize(width: 540, height: 520)
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unifiedCompact)
        .windowStyle(.hiddenTitleBar)
    }
}
