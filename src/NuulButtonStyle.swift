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
            .foregroundStyle(kind == .primary ? Color.black : Nuul.ink)
            .frame(minWidth: Nuul.Layout.controlHeight, minHeight: Nuul.Layout.controlHeight)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: Nuul.Radius.control))
            .overlay {
                if kind == .neutral {
                    RoundedRectangle(cornerRadius: Nuul.Radius.control)
                        .strokeBorder(Nuul.controlRule, lineWidth: 1)
                }

                if configuration.isPressed && kind != .quiet {
                    RoundedRectangle(cornerRadius: Nuul.Radius.control)
                        .fill(Nuul.itemText.opacity(0.10))
                }
            }
            .contentShape(Rectangle())
            .opacity(isEnabled ? (configuration.isPressed ? 0.84 : 1) : 0.42)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1)
            .animation(reduceMotion ? nil : Nuul.controlMotion, value: configuration.isPressed)
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
