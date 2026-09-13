import XCTest
@testable import Colorway

final class ColorwayColorTests: XCTestCase {
    func testRgbConversionAndHexRoundTrip() {
        XCTAssertEqual(ColorwayColor(red: 1, green: 0, blue: 0).hex, "#FF0000")
        XCTAssertEqual(ColorwayColor(red: 0, green: 1, blue: 0).hex, "#00FF00")
        XCTAssertEqual(ColorwayColor(red: 0, green: 0, blue: 1).hex, "#0000FF")
        XCTAssertEqual(ColorwayColor(red: 0.5, green: 0.5, blue: 0.5).hex, "#808080")

        let source = ColorwayColor.fromHex("  #3a7bd5\n")
        XCTAssertEqual(source?.hex, "#3A7BD5")
        XCTAssertNil(ColorwayColor.fromHex("#12"))
        XCTAssertNil(ColorwayColor.fromHex("not-a-color"))
    }

    func testInitializersClampInputs() {
        let hsb = ColorwayColor(hue: -1, saturation: 2, brightness: 0.5)
        XCTAssertEqual(hsb.hue, 0)
        XCTAssertEqual(hsb.saturation, 1)
        XCTAssertEqual(hsb.brightness, 0.5)

        let rgb = ColorwayColor(red: -1, green: 2, blue: 0.25)
        XCTAssertEqual(rgb.hex, "#00FF40")
    }

    func testHsbSectorsAndContrastingInk() {
        for sector in 0..<6 {
            let color = ColorwayColor(
                hue: (Double(sector) + 0.25) / 6,
                saturation: 1,
                brightness: 1
            )
            XCTAssertFalse(color.hex.isEmpty)
        }

        XCTAssertEqual(ColorwayColor(hue: 0, saturation: 0, brightness: 0.4).hex, "#666666")
        XCTAssertEqual(ColorwayColor(red: 1, green: 1, blue: 1).contrastingInk, .black)
        XCTAssertEqual(ColorwayColor(red: 1, green: 0, blue: 0).contrastingInk, .white)
    }

    func testHarmonyVariants() {
        let source = ColorwayColor(hue: 0.9, saturation: 0.7, brightness: 0.8)

        XCTAssertEqual(ColorHarmony.complementary.colors(for: source).count, 2)
        XCTAssertEqual(ColorHarmony.analogous.colors(for: source).count, 3)
        XCTAssertEqual(ColorHarmony.triadic.colors(for: source).count, 3)
        XCTAssertEqual(ColorHarmony.tetradic.colors(for: source).count, 4)

        let monochrome = ColorHarmony.monochrome.colors(for: source)
        XCTAssertEqual(monochrome.count, 4)
        XCTAssertEqual(monochrome.last?.brightness, source.brightness)
        XCTAssertEqual(ColorHarmony.allCases.map(\.title), [
            "Complementary", "Analogous", "Triadic", "Tetradic", "Monochrome"
        ])
        XCTAssertEqual(ColorHarmony.allCases.map(\.id), ColorHarmony.allCases)
    }
}
