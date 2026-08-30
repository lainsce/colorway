import AppKit
import SwiftUI

struct HarmonyPaletteButton: View {
    let color: ColorwayColor

    @State private var isHovered = false

    var body: some View {
        Button(action: copyColor) {
            color.swiftUIColor
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityHidden(true)
        }
        .buttonStyle(
            HarmonyPaletteButtonStyle(
                isHovered: isHovered,
                iconColor: color.contrastingInk
            )
        )
        .onHover { hovering in
            isHovered = hovering
        }
        .accessibilityLabel("Copy \(color.hex)")
        .accessibilityHint("Copies this color to the clipboard")
        .help("Copy \(color.hex)")
    }

    private func copyColor() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(color.hex, forType: .string)
    }
}

struct HarmonyPaletteButtonStyle: ButtonStyle {
    let isHovered: Bool
    let iconColor: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            configuration.label

            ZStack {
                Image(systemName: "doc.on.doc")
                    .opacity(configuration.isPressed ? 0 : 1)

                Image(systemName: "checkmark.circle.fill")
                    .opacity(configuration.isPressed ? 1 : 0)
            }
            .font(Nuul.Typography.symbol)
            .foregroundStyle(iconColor)
            .opacity(isHovered ? 1 : 0)
            .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .animation(
            reduceMotion ? nil : Nuul.controlMotion,
            value: configuration.isPressed
        )
        .animation(
            reduceMotion ? nil : Nuul.controlMotion,
            value: isHovered
        )
    }
}
