import SwiftUI

enum ColorwayWindowID {
    static let about = "about"
    static let privacyPolicy = "privacy-policy"
}

struct ColorwayCommands: Commands {
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button("About Colorway", systemImage: "info.circle") {
                openWindow(id: ColorwayWindowID.about)
            }
        }

        CommandGroup(after: .help) {
            Button("Privacy Policy", systemImage: "hand.raised") {
                openWindow(id: ColorwayWindowID.privacyPolicy)
            }
        }
    }
}
