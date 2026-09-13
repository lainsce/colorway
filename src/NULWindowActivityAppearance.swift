import SwiftUI

/// Removes chroma from a window while it is inactive, preserving its layout and controls.
struct NULWindowActivityAppearance: ViewModifier {
    @Environment(\.appearsActive) private var appearsActive
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .saturation(appearsActive ? 1 : 0)
            .animation(
                reduceMotion ? nil : .easeInOut(duration: 0.18),
                value: appearsActive
            )
    }
}

extension View {
    func nulWindowActivityAppearance() -> some View {
        modifier(NULWindowActivityAppearance())
    }
}
