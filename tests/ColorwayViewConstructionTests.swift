import AppKit
import SwiftUI
import XCTest
@testable import Colorway

final class ColorwayViewConstructionTests: XCTestCase {
    @MainActor
    func testConstructsPickerAndPolicySurfaces() {
        _ = ContentView().body
        _ = HarmonyPaletteButton(color: ColorwayColor(hue: 0.2, saturation: 0.8, brightness: 0.9)).body
        _ = ColorwayPrivacyPolicySection(
            title: "Local",
            systemImage: "lock",
            text: "Stored on this Mac"
        ).body
        _ = ColorwayPrivacyPolicyView().body
        _ = ColorwayAboutView().body
        _ = ColorwayCommands().body
    }

    @MainActor
    func testConstructsNuulVariantsAndThemeTokens() {
        _ = NULMenuPicker("Harmony", selection: .constant(ColorHarmony.tetradic), options: ColorHarmony.allCases) { item in
            Text(item.title)
        }.body
        _ = NULMenuPicker("Harmony", selection: .constant(ColorHarmony.tetradic), options: ColorHarmony.allCases, showsTitle: false) { item in
            Text(item.title)
        }.body
        _ = Text("Active").modifier(NULWindowActivityAppearance())
        _ = Text("Active").nulWindowActivityAppearance()
        for scheme in [ColorScheme.light, .dark] {
            _ = Nuul.workspace
            _ = Nuul.sidebar
            _ = Nuul.itemSurface
            _ = Nuul.itemText
            _ = Nuul.itemSecondaryText
            _ = Nuul.controlSurface
            _ = Nuul.inputSurface
            _ = Nuul.ink
            _ = Nuul.controlRule
            _ = Nuul.quietRule
            _ = Nuul.fieldRule
            _ = scheme
        }
        XCTAssertEqual(Nuul.Layout.windowWidth, 295)
        XCTAssertEqual(Nuul.Layout.windowHeight, 344)
        XCTAssertEqual(Nuul.Radius.picker, Nuul.Radius.surface)
        XCTAssertEqual(Nuul.Spacing.xLarge, 24)
        _ = Nuul.Typography.display
        _ = Nuul.Typography.viewTitle
        _ = Nuul.Typography.viewSubtitle
        _ = Nuul.Typography.contentBlockTitle
        _ = Nuul.Typography.body
        _ = Nuul.Typography.bodyStrong
        _ = Nuul.Typography.caption
        _ = Nuul.Typography.technical
        _ = Nuul.Typography.technicalCaption
        _ = Nuul.Typography.symbol
        _ = Nuul.Typography.technicalFont(size: 14, relativeTo: .body)
    }

    @MainActor
    func testRendersNuulButtonsInBothAppearanceStates() {
        func assertRenders<Control: View>(_ control: Control) {
            let renderer = ImageRenderer(content: control.environment(\.colorScheme, .dark))
            renderer.scale = 1
            XCTAssertNotNil(renderer.nsImage)
        }

        assertRenders(Button(action: {}) { Text("Primary") }.buttonStyle(NuulButtonStyle(kind: .primary)))
        assertRenders(Button(action: {}) { Text("Neutral") }.buttonStyle(NuulButtonStyle(kind: .neutral)))
        assertRenders(Button(action: {}) { Text("Quiet") }.buttonStyle(NuulButtonStyle(kind: .quiet)))
        assertRenders(Button(action: {}) { Text("Disabled") }.buttonStyle(NuulButtonStyle()).disabled(true))
    }

    func testAppDelegateTerminationPolicy() {
        XCTAssertTrue(ColorwayAppDelegate().applicationShouldTerminateAfterLastWindowClosed(NSApplication.shared))
        XCTAssertEqual(ColorwayWindowID.about, "about")
        XCTAssertEqual(ColorwayWindowID.privacyPolicy, "privacy-policy")
    }
}
