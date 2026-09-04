import AppKit
import SwiftUI

struct ContentView: View {
    @State private var color: ColorwayColor = .fromHex("#3C93FD") ?? ColorwayColor(hue: 0.58, saturation: 0.76, brightness: 0.99)
    @State private var hexInput = "#3C93FD"
    @State private var harmony: ColorHarmony = .tetradic

    var body: some View {
        ZStack {
            Nuul.workspace
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ColorEntryField(
                    text: $hexInput,
                    onCommit: applyHexInput
                )

                ColorPickerSurface(color: $color)
                    .padding(.top, Nuul.Spacing.large)

                HarmonyPalette(colors: harmony.colors(for: color))
                    .padding(.top, Nuul.Spacing.large)

                PickerActions(
                    harmony: $harmony,
                    color: color,
                    onSample: sampleColor
                )
                .padding(.top, Nuul.Spacing.large)
            }
            .padding(.top, Nuul.Spacing.large)
            .padding(.bottom, Nuul.Spacing.large)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(width: Nuul.Layout.windowWidth, height: Nuul.Layout.windowHeight)
        .onChange(of: color, initial: false) { _, newColor in
            hexInput = newColor.hex
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Colorway color picker")
        .toolbar {
            ToolbarSpacer(placement: .navigation)
                .sharedBackgroundVisibility(.hidden)

            ToolbarItem(placement: .primaryAction) {
                NuulToolbarMenu("Color options", systemImage: "ellipsis") {
                    Button("Copy hex", action: copyHex)
                    Button("Reset color", action: resetColor)
                }
            }
            .sharedBackgroundVisibility(.hidden)
        }
    }

    private func applyHexInput() {
        guard let newColor = ColorwayColor.fromHex(hexInput) else {
            hexInput = color.hex
            return
        }

        color = newColor
        hexInput = newColor.hex
    }

    private func sampleColor() {
        NSColorSampler().show { sampledColor in
            guard let sampledColor else { return }
            guard let rgb = sampledColor.usingColorSpace(.sRGB) else { return }

            color = ColorwayColor(
                red: rgb.redComponent,
                green: rgb.greenComponent,
                blue: rgb.blueComponent
            )
        }
    }

    private func copyHex() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(hexInput.uppercased(), forType: .string)
    }

    private func resetColor() {
        hexInput = "#3C93FD"
        applyHexInput()
    }

}

private struct ColorEntryField: View {
    @Binding var text: String
    let onCommit: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: Nuul.Spacing.medium) {
            TextField("Hex color", text: $text)
                .textFieldStyle(.plain)
                .font(Nuul.Typography.technical)
                .foregroundStyle(Nuul.ink)
                .textCase(.uppercase)
                .padding(.horizontal, Nuul.Spacing.medium)
                .frame(
                    maxWidth: .infinity,
                    minHeight: Nuul.Layout.fieldHeight,
                    maxHeight: Nuul.Layout.fieldHeight
                )
                .background(Nuul.itemSurface, in: RoundedRectangle(cornerRadius: Nuul.Radius.control))
                .overlay {
                    RoundedRectangle(cornerRadius: Nuul.Radius.control)
                        .strokeBorder(
                            isFocused ? Nuul.fieldRule : Nuul.controlRule,
                            lineWidth: isFocused ? 2 : 1
                        )
                }
                .contentShape(.rect(cornerRadius: Nuul.Radius.control))
                .focused($isFocused)
                .onSubmit {
                    onCommit()
                    isFocused = false
                }
                .accessibilityLabel("Hex color")
        }
        .padding(.horizontal, Nuul.Spacing.large)
        .frame(height: Nuul.Layout.controlHeight)
    }
}

private struct ColorPickerSurface: View {
    @Binding var color: ColorwayColor

    var body: some View {
        HStack(spacing: Nuul.Spacing.large) {
            SaturationBrightnessSurface(color: $color)
                .frame(height: Nuul.Layout.pickerHeight)
            HueRail(hue: $color.hue)
                .frame(height: Nuul.Layout.hueRailHeight)
                .offset(x: Nuul.Layout.hueRailOffsetX)
        }
        .padding(.horizontal, Nuul.Spacing.large)
        .frame(height: Nuul.Layout.hueRailHeight)
    }
}

private struct SaturationBrightnessSurface: View {
    @Binding var color: ColorwayColor

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hue: color.hue, saturation: 1, brightness: 1)

                LinearGradient(
                    colors: [.white, .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )

                LinearGradient(
                    colors: [.clear, .black],
                    startPoint: .top,
                    endPoint: .bottom
                )

                Circle()
                    .fill(.white)
                    .frame(width: 8, height: 8)
                    .overlay {
                        Circle()
                            .stroke(.black, lineWidth: 2)
                    }
                    .position(
                        x: color.saturation * geometry.size.width,
                        y: (1 - color.brightness) * geometry.size.height
                    )
                    .allowsHitTesting(false)
            }
            .clipShape(RoundedRectangle(cornerRadius: Nuul.Radius.picker, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: Nuul.Radius.picker, style: .continuous))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let x = min(max(value.location.x, 0), geometry.size.width)
                        let y = min(max(value.location.y, 0), geometry.size.height)
                        color.saturation = x / geometry.size.width
                        color.brightness = 1 - (y / geometry.size.height)
                    }
            )
            .accessibilityElement()
            .accessibilityLabel("Color saturation and brightness")
            .accessibilityValue("\(color.hex)")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment:
                    color.brightness = min(color.brightness + 0.05, 1)
                case .decrement:
                    color.brightness = max(color.brightness - 0.05, 0)
                @unknown default:
                    break
                }
            }
        }
        .frame(width: Nuul.Layout.colorSurfaceWidth)
    }
}

private struct HueRail: View {
    @Binding var hue: Double

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { geometry in
            let indicatorInk = colorScheme == .dark ? Color.white : Color.black

            ZStack {
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .red, location: 0),
                        .init(color: .yellow, location: 1 / 6),
                        .init(color: .green, location: 2 / 6),
                        .init(color: .cyan, location: 3 / 6),
                        .init(color: .blue, location: 4 / 6),
                        .init(color: .purple, location: 5 / 6),
                        .init(color: .red, location: 1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(Capsule())
                .frame(width: Nuul.Layout.hueRailWidth, height: Nuul.Layout.hueRailHeight)

                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(indicatorInk)
                        .frame(
                            width: Nuul.Layout.hueIndicatorLineWidth,
                            height: Nuul.Layout.hueIndicatorLineThickness
                        )
                        .offset(x: Nuul.Layout.hueIndicatorLineOffsetX)

                    HueDialTriangle()
                        .fill(indicatorInk)
                        .frame(width: Nuul.Layout.hueDialWidth, height: Nuul.Layout.hueDialHeight)
                        .offset(x: Nuul.Layout.hueDialOffsetX)
                }
                .offset(y: hue * geometry.size.height - geometry.size.height / 2)
            }
            .frame(width: Nuul.Layout.hueRailWidth, height: Nuul.Layout.hueRailHeight)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        hue = min(max(value.location.y / geometry.size.height, 0), 1)
                    }
            )
            .accessibilityElement()
            .accessibilityLabel("Hue")
            .accessibilityValue("\(Int(hue * 360)) degrees")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment:
                    hue = min(hue + 0.02, 1)
                case .decrement:
                    hue = max(hue - 0.02, 0)
                @unknown default:
                    break
                }
            }
        }
        .frame(width: Nuul.Layout.hueRailWidth, height: Nuul.Layout.hueRailHeight)
    }
}

private struct HueDialTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        let dialRect = rect.insetBy(dx: 1, dy: 2)
        let tip = CGPoint(x: dialRect.minX, y: dialRect.midY)
        let top = CGPoint(x: dialRect.maxX, y: dialRect.minY)
        let bottom = CGPoint(x: dialRect.maxX, y: dialRect.maxY)

        let tipToTop = point(from: tip, toward: top, distance: Nuul.Layout.hueDialCornerRadius)
        let topToTip = point(from: top, toward: tip, distance: Nuul.Layout.hueDialCornerRadius)
        let topToBottom = point(from: top, toward: bottom, distance: Nuul.Layout.hueDialCornerRadius)
        let bottomToTop = point(from: bottom, toward: top, distance: Nuul.Layout.hueDialCornerRadius)
        let bottomToTip = point(from: bottom, toward: tip, distance: Nuul.Layout.hueDialCornerRadius)
        let tipToBottom = point(from: tip, toward: bottom, distance: Nuul.Layout.hueDialCornerRadius)

        var path = Path()
        path.move(to: tipToTop)
        path.addLine(to: topToTip)
        path.addQuadCurve(to: topToBottom, control: top)
        path.addLine(to: bottomToTop)
        path.addQuadCurve(to: bottomToTip, control: bottom)
        path.addLine(to: tipToBottom)
        path.addQuadCurve(to: tipToTop, control: tip)
        path.closeSubpath()
        return path
    }

    private func point(from start: CGPoint, toward end: CGPoint, distance: CGFloat) -> CGPoint {
        let deltaX = end.x - start.x
        let deltaY = end.y - start.y
        let length = hypot(deltaX, deltaY)
        guard length > 0 else { return start }

        let fraction = min(distance / length, 0.5)
        return CGPoint(
            x: start.x + deltaX * fraction,
            y: start.y + deltaY * fraction
        )
    }
}

private struct HarmonyPalette: View {
    let colors: [ColorwayColor]

    var body: some View {
        HStack(spacing: 1) {
            ForEach(Array(colors.enumerated()), id: \.offset) { _, color in
                HarmonyPaletteButton(color: color)
            }
        }
        .frame(width: Nuul.Layout.paletteWidth, height: Nuul.Layout.paletteHeight)
        .clipShape(Capsule())
        .contentShape(Capsule())
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(colors.count)-color harmony palette")
    }
}

private struct PickerActions: View {
    @Binding var harmony: ColorHarmony
    let color: ColorwayColor
    let onSample: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            NULMenuPicker(
                "Color harmony",
                selection: $harmony,
                options: ColorHarmony.allCases,
                showsTitle: false
            ) { item in
                Text(item.title)
            }
            .frame(width: Nuul.Layout.harmonyWidth, height: Nuul.Layout.controlHeight, alignment: .leading)
            .accessibilityLabel("Color harmony")
            .accessibilityValue(harmony.title)

            Spacer(minLength: 0)

            Button(action: onSample) {
                Image(systemName: "eyedropper.halffull")
                    .font(Nuul.Typography.symbol)
            }
            .buttonStyle(NuulButtonStyle(kind: .primary, accentColor: color.swiftUIColor))
            .accessibilityLabel("Pick a color from the screen")
        }
        .padding(.horizontal, Nuul.Spacing.large)
        .frame(height: Nuul.Layout.controlHeight)
    }
}
