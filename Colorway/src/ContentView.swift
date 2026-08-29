import AppKit
import SwiftUI

struct ContentView: View {
    @State private var color: ColorwayColor = .fromHex("#3C93FD") ?? ColorwayColor(hue: 0.58, saturation: 0.76, brightness: 0.99)
    @State private var hexInput = "#3C93FD"
    @State private var harmony: ColorHarmony = .tetradic

    var body: some View {
        ZStack {
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
                .focused($isFocused)
                .onSubmit {
                    onCommit()
                    isFocused = false
                }
                .accessibilityLabel("Hex color")

            Spacer(minLength: 0)

            Menu {
                Button("Copy hex", action: copyHex)
                Button("Reset color", action: resetColor)
            } label: {
                Image(systemName: "ellipsis")
                    .font(Nuul.Typography.symbol)
                    .foregroundStyle(Nuul.ink)
                    .frame(width: Nuul.Layout.controlHeight, height: Nuul.Layout.controlHeight)
                    .background(Nuul.controlSurface, in: RoundedRectangle(cornerRadius: Nuul.Radius.control))
            }
            .menuStyle(.borderlessButton)
            .accessibilityLabel("Color options")
        }
        .padding(.horizontal, Nuul.Spacing.large)
        .frame(height: Nuul.Layout.controlHeight)
    }

    private func copyHex() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text.uppercased(), forType: .string)
    }

    private func resetColor() {
        text = "#3C93FD"
        onCommit()
    }
}

private struct ColorPickerSurface: View {
    @Binding var color: ColorwayColor

    var body: some View {
        HStack(spacing: Nuul.Spacing.medium) {
            SaturationBrightnessSurface(color: $color)
            HueRail(hue: $color.hue)
        }
        .padding(.horizontal, Nuul.Spacing.large)
        .frame(height: Nuul.Layout.pickerHeight)
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

    var body: some View {
        GeometryReader { geometry in
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

                Circle()
                    .stroke(.white, lineWidth: 3)
                    .background(Circle().fill(.clear))
                    .frame(width: 21, height: 21)
                    .position(x: geometry.size.width / 2, y: hue * geometry.size.height)
                    .allowsHitTesting(false)
            }
            .clipShape(RoundedRectangle(cornerRadius: Nuul.Radius.control, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: Nuul.Radius.control, style: .continuous))
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
        .frame(width: Nuul.Layout.hueRailWidth)
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
            Picker("Color harmony", selection: $harmony) {
                ForEach(ColorHarmony.allCases) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .font(Nuul.Typography.body)
            .foregroundStyle(Nuul.ink)
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
