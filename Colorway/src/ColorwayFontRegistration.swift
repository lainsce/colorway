import CoreText
import Foundation

enum ColorwayFontRegistration {
    private static let fontNames = [
        "Geist-Regular",
        "Geist-Medium",
        "Geist-SemiBold",
        "Geist-Bold",
        "Geist-Black",
        "GeistMono-Variable"
    ]

    static func register() {
        for fontName in fontNames {
            guard let url = Bundle.main.url(forResource: fontName, withExtension: "ttf", subdirectory: "Fonts")
                ?? Bundle.main.url(forResource: fontName, withExtension: "ttf") else {
                continue
            }

            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
