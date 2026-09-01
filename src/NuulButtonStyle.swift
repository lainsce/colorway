import SwiftUI

/// The compact Nuul button treatment shown in the shared component board.
struct NuulButtonStyle: ButtonStyle {
    enum Kind {
        case primary
        case neutral
        case quiet
    }

    let kind: Kind
    let accentColor: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    init(kind: Kind = .primary, accentColor: Color = .accent) {
        self.kind = kind
        self.accentColor = accentColor
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Nuul.Typography.body)
            .symbolRenderingMode(.monochrome)
            .foregroundStyle(foregroundColor)
            .frame(minWidth: Nuul.Layout.controlHeight, minHeight: Nuul.Layout.controlHeight)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: Nuul.Radius.control))
            .overlay { overlayContent(isPressed: configuration.isPressed) }
            .contentShape(Rectangle())
            .opacity(controlOpacity(isPressed: configuration.isPressed))
            .scaleEffect(controlScale(isPressed: configuration.isPressed))
            .animation(reduceMotion ? nil : Nuul.controlMotion, value: configuration.isPressed)
            .nulWindowActivityAppearance()
    }

    @ViewBuilder
    private func overlayContent(isPressed: Bool) -> some View {
        if kind == .neutral {
            RoundedRectangle(cornerRadius: Nuul.Radius.control)
                .strokeBorder(Nuul.controlRule, lineWidth: 1)
        }

        if isPressed && kind != .quiet {
            RoundedRectangle(cornerRadius: Nuul.Radius.control)
                .fill(Nuul.itemText.opacity(0.10))
        }
    }

    private func controlOpacity(isPressed: Bool) -> Double {
        guard isEnabled else { return 0.42 }
        return isPressed ? 0.84 : 1
    }

    private func controlScale(isPressed: Bool) -> Double {
        guard isPressed, !reduceMotion else { return 1 }
        return 0.98
    }

    private var foregroundColor: Color {
        kind == .primary ? .black : Nuul.ink
    }

    private var backgroundColor: Color {
        switch kind {
        case .primary:
            accentColor
        case .neutral, .quiet:
            Nuul.itemSurface
        }
    }
}
