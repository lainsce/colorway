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
    }
}
