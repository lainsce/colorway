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
    let horizontalPadding: CGFloat?
    let labelColor: Color?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    init(
        kind: Kind = .primary,
        accentColor: Color = Nuul.accent,
        horizontalPadding: CGFloat? = nil,
        labelColor: Color? = nil
    ) {
        self.kind = kind
        self.accentColor = accentColor
        self.horizontalPadding = horizontalPadding
        self.labelColor = labelColor
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Nuul.Typography.contentBlockSubtitle)
            .symbolRenderingMode(.monochrome)
            .foregroundStyle(labelColor ?? foregroundColor)
            .padding(.horizontal, horizontalPadding ?? (kind == .quiet ? Nuul.Spacing.small : Nuul.Spacing.medium))
            .frame(minWidth: Nuul.Layout.controlHeight, minHeight: Nuul.Layout.controlHeight)
            .background(
                backgroundColor,
                in: RoundedRectangle(cornerRadius: Nuul.Radius.control, style: .continuous)
            )
            .overlay { pressedOverlay(isPressed: configuration.isPressed) }
            .contentShape(.rect(cornerRadius: Nuul.Radius.control))
            .opacity(controlOpacity(isPressed: configuration.isPressed))
            .scaleEffect(controlScale(isPressed: configuration.isPressed))
            .animation(reduceMotion ? nil : Nuul.controlMotion, value: configuration.isPressed)
            .nulWindowActivityAppearance()
    }

    @ViewBuilder
    private func pressedOverlay(isPressed: Bool) -> some View {
        if isPressed && kind != .quiet {
            RoundedRectangle(cornerRadius: Nuul.Radius.control, style: .continuous)
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
