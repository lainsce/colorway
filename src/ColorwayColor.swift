import Foundation
import SwiftUI

struct ColorwayColor: Equatable {
    var hue: Double
    var saturation: Double
    var brightness: Double

    init(hue: Double, saturation: Double, brightness: Double) {
        self.hue = hue.clamped(to: 0...1)
        self.saturation = saturation.clamped(to: 0...1)
        self.brightness = brightness.clamped(to: 0...1)
    }

    init(red: Double, green: Double, blue: Double) {
        let red = red.clamped(to: 0...1)
        let green = green.clamped(to: 0...1)
        let blue = blue.clamped(to: 0...1)
        let maximum = max(red, max(green, blue))
        let minimum = min(red, min(green, blue))
        let range = maximum - minimum

        brightness = maximum
        saturation = maximum == 0 ? 0 : range / maximum
        hue = Self.normalizedHue(red: red, green: green, blue: blue, maximum: maximum, range: range)
    }

    private static func normalizedHue(
        red: Double,
        green: Double,
        blue: Double,
        maximum: Double,
        range: Double
    ) -> Double {
        guard range != 0 else { return 0 }

        let hue = hueComponent(
            red: red,
            green: green,
            blue: blue,
            maximum: maximum,
            range: range
        )
        return hue < 0 ? hue + 1 : hue
    }

    private static func hueComponent(
        red: Double,
        green: Double,
        blue: Double,
        maximum: Double,
        range: Double
    ) -> Double {
        maximum == red
            ? ((green - blue) / range).truncatingRemainder(dividingBy: 6) / 6
            : maximum == green
                ? (((blue - red) / range) + 2) / 6
                : (((red - green) / range) + 4) / 6
    }

    var swiftUIColor: Color {
        Color(hue: hue, saturation: saturation, brightness: brightness)
    }

    var contrastingInk: Color {
        let rgb = rgbComponents
        let luminance = 0.299 * rgb.red + 0.587 * rgb.green + 0.114 * rgb.blue
        return luminance > 0.58 ? .black : .white
    }

    var hex: String {
        let rgb = rgbComponents
        return String(
            format: "#%02X%02X%02X",
            Int((rgb.red * 255).rounded()),
            Int((rgb.green * 255).rounded()),
            Int((rgb.blue * 255).rounded())
        )
    }

    static func fromHex(_ value: String) -> ColorwayColor? {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        guard normalized.count == 6, let integer = UInt32(normalized, radix: 16) else {
            return nil
        }

        return ColorwayColor(
            red: Double((integer >> 16) & 0xFF) / 255,
            green: Double((integer >> 8) & 0xFF) / 255,
            blue: Double(integer & 0xFF) / 255
        )
    }

    private var rgbComponents: (red: Double, green: Double, blue: Double) {
        guard saturation > 0 else {
            return (brightness, brightness, brightness)
        }

        let scaledHue = hue * 6
        let sector = Int(floor(scaledHue))
        let fraction = scaledHue - floor(scaledHue)
        let p = brightness * (1 - saturation)
        let q = brightness * (1 - saturation * fraction)
        let t = brightness * (1 - saturation * (1 - fraction))

        switch sector % 6 {
        case 0: return (brightness, t, p)
        case 1: return (q, brightness, p)
        case 2: return (p, brightness, t)
        case 3: return (p, q, brightness)
        case 4: return (t, p, brightness)
        default: return (brightness, p, q)
        }
    }
}

enum ColorHarmony: String, CaseIterable, Identifiable {
    case complementary
    case analogous
    case triadic
    case tetradic
    case monochrome

    var id: Self { self }

    var title: String {
        rawValue.capitalized
    }

    func colors(for color: ColorwayColor) -> [ColorwayColor] {
        if self == .monochrome { return monochromeColors(for: color) }

        return hueOffsets.map { offset in
            ColorwayColor(
                hue: (color.hue + offset).wrappedUnit,
                saturation: color.saturation,
                brightness: color.brightness
            )
        }
    }

    private func monochromeColors(for color: ColorwayColor) -> [ColorwayColor] {
        [0.25, 0.5, 0.75, 1].map { factor in
            ColorwayColor(
                hue: color.hue,
                saturation: color.saturation,
                brightness: color.brightness * factor
            )
        }
    }

    private var hueOffsets: [Double] {
        switch self {
        case .monochrome: []
        case .complementary: [0, 0.5]
        case .analogous: [-0.08, 0, 0.08]
        case .triadic: [0, 1 / 3, 2 / 3]
        case .tetradic: [0, 0.5, 0.75, 0.25]
        }
    }
}

private extension Double {
    var wrappedUnit: Double {
        let result = truncatingRemainder(dividingBy: 1)
        return result < 0 ? result + 1 : result
    }

    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
