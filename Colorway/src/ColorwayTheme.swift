import AppKit
import SwiftUI

enum Nuul {
    // Nuul foundations: the app workspace and the opaque item surface are
    // deliberately separate layers. Keeping these values centralized makes
    // the picker feel like a native Nuul surface instead of a collection of
    // ad-hoc grays.
    static let workspace = dynamicColor(
        light: NSColor(srgbRed: 242 / 255, green: 242 / 255, blue: 242 / 255, alpha: 1),
        dark: NSColor.black
    )
    static let sidebar = dynamicColor(
        light: NSColor(srgbRed: 228 / 255, green: 228 / 255, blue: 228 / 255, alpha: 1),
        dark: NSColor(srgbRed: 42 / 255, green: 42 / 255, blue: 42 / 255, alpha: 1)
    )
    static let itemSurface = dynamicColor(
        light: NSColor(srgbRed: 253 / 255, green: 253 / 255, blue: 253 / 255, alpha: 1),
        dark: NSColor(srgbRed: 17 / 255, green: 17 / 255, blue: 17 / 255, alpha: 1)
    )
    static let itemText = dynamicColor(light: NSColor.black, dark: NSColor.white)
    static let itemSecondaryText = dynamicColor(
        light: NSColor.black.withAlphaComponent(0.56),
        dark: NSColor.white.withAlphaComponent(0.56)
    )

    static let controlSurface = workspace
    static let inputSurface = workspace
    static let ink = itemText
    static let controlRule = dynamicColor(
        light: NSColor.black.withAlphaComponent(0.12),
        dark: NSColor.white.withAlphaComponent(0.16)
    )
    static let quietRule = dynamicColor(
        light: NSColor.black.withAlphaComponent(0.06),
        dark: NSColor.white.withAlphaComponent(0.08)
    )
    static let fieldRule = dynamicColor(
        light: NSColor.black.withAlphaComponent(0.72),
        dark: NSColor.white.withAlphaComponent(0.72)
    )
    static let controlMotion = Animation.spring(response: 0.24, dampingFraction: 0.88)
    static let navigationMotion = Animation.spring(response: 0.34, dampingFraction: 0.84)

    enum Spacing {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 24
    }

    enum Radius {
        static let control: CGFloat = 4
        static let surface: CGFloat = 12
        static let picker = surface
    }

    enum Layout {
        static let windowWidth: CGFloat = 295
        static let windowHeight: CGFloat = 344
        static let controlHeight: CGFloat = 38
        static let fieldHeight: CGFloat = 36
        static let colorSurfaceWidth: CGFloat = 232
        static let hueRailWidth: CGFloat = 20
        static let pickerHeight: CGFloat = 150
        static let paletteWidth: CGFloat = 258
        static let paletteHeight: CGFloat = 38
        static let harmonyWidth: CGFloat = 140
    }

    enum Typography {
        static let body = Font.custom("Geist-Regular", size: 14, relativeTo: .body)
        static let bodyStrong = Font.custom("Geist-SemiBold", size: 14, relativeTo: .body)
        static let technical = Font.custom("Geist Mono", size: 14, relativeTo: .body)
        static let symbol = Font.system(size: 22, weight: .regular)
    }

    private static func dynamicColor(light: NSColor, dark: NSColor) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? dark : light
        })
    }
}
