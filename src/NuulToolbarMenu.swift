import SwiftUI

/// Native Liquid Glass menu button used by the toolbar.
struct NULToolbarMenu<Content: View>: View {
    private let title: LocalizedStringKey
    private let systemImage: String
    private let menuContent: () -> Content

    init(
        _ title: LocalizedStringKey,
        systemImage: String,
        @ViewBuilder menuContent: @escaping () -> Content
    ) {
        self.title = title
        self.systemImage = systemImage
        self.menuContent = menuContent
    }

    var body: some View {
        Menu {
            menuContent()
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: Nuul.Layout.toolbarGlyphSize, weight: .regular))
                .symbolRenderingMode(.monochrome)
        }
        .menuStyle(.button)
        .menuIndicator(.hidden)
        .frame(width: Nuul.Layout.toolbarControlSize)
        .accessibilityLabel(Text(title))
        .help(Text(title))
    }
}
