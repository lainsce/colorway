import SwiftUI

/// Nuul's toolbar menu: a native menu with one flat square surface and a
/// matching square hover state instead of AppKit's nested circular highlight.
struct NuulToolbarMenu<Content: View>: View {
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
            NuulToolbarMenuLabel(systemImage: systemImage)
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .accessibilityLabel(Text(title))
        .help(Text(title))
        .nulWindowActivityAppearance()
    }
}

private struct NuulToolbarMenuLabel: View {
    let systemImage: String

    @Environment(\.colorScheme) private var colorScheme
    @State private var isHovered = false

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 16, weight: .regular))
            .symbolRenderingMode(.monochrome)
            .foregroundStyle(Nuul.ink)
            .frame(width: Nuul.Layout.toolbarIconSize, height: Nuul.Layout.toolbarIconSize)
            .frame(width: Nuul.Layout.controlHeight, height: Nuul.Layout.controlHeight)
            .background {
                RoundedRectangle(cornerRadius: Nuul.Radius.control, style: .continuous)
                    .fill(Nuul.itemSurface)

                RoundedRectangle(cornerRadius: Nuul.Radius.control, style: .continuous)
                    .fill(hoverFill)
            }
            .contentShape(.rect(cornerRadius: Nuul.Radius.control))
            .onHover { isHovered = $0 }
    }

    private var hoverFill: Color {
        isHovered
            ? Nuul.itemText.opacity(colorScheme == .dark ? 0.13 : 0.08)
            : .clear
    }
}
