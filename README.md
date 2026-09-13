# Colorway

## A focused color picker for exploring color relationships

Colorway is a native macOS app for picking colors, inspecting their HEX values, and exploring common harmony relationships in a compact Nuul-styled interface. Use the saturation/brightness surface and hue rail to choose a color, then switch between complementary, analogous, triadic, tetradic, and monochrome palettes. Each harmony swatch can be copied independently.

## What you can do

- **Pick** colors from the saturation/brightness surface and hue rail
- **Sample** a color anywhere on screen with the system color sampler
- **Enter** exact values through the HEX field
- **Explore** complementary, analogous, triadic, tetradic, and monochrome harmonies
- **Copy** the selected HEX value or any individual harmony swatch
- **Reset** to the default color from the options menu

Colorway keeps its picker and clipboard interactions native to macOS while using the Nuul window bridge. The interface uses Geist typography and Nuul's compact spacing, surfaces, control metrics, and motion guidance.

## Requirements

- macOS 27 or later
- Xcode 27 or later
- Swift 5 language mode

Colorway is currently an unsigned development project. Signing, notarization, and App Store distribution are intentionally not configured yet.

## Build

Clone the repository and open the Xcode project:

```bash
git clone https://github.com/lainsce/colorway.git
cd colorway
open Colorway.xcodeproj
```

To build an unsigned macOS app from Terminal:

```bash
xcodebuild \
  -project Colorway.xcodeproj \
  -scheme Colorway \
  -configuration Debug \
  -sdk macosx \
  -derivedDataPath /tmp/Colorway-DerivedData \
  build \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO
```

## Project layout

```text
Colorway/                    application source and resources
  src/                       SwiftUI views, color model, theme, and styles
  data/                      asset catalog, icon, and bundled fonts
Colorway.xcodeproj/          Xcode project and shared build settings
```

The `Colorway/data/` folder is part of the repository so a fresh checkout contains every resource required by the project, including the bundled Geist fonts.

## Development checks

For a fast source-only parse:

```bash
find Colorway/src -name '*.swift' -print0 | \
  xargs -0 xcrun swiftc -frontend -parse \
  -sdk /Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
```

Asset and icon metadata can be checked with:

```bash
find Colorway/data/Assets.xcassets Colorway/data/Colorway.icon -name '*.json' -print0 | \
  xargs -0 -n1 jq empty
```

## Privacy

Colorway is a local-first utility. It has no account or network service, and color values stay on this Mac. The system color sampler is used only when you request a screen color.

An in-app Privacy Policy is available from the Help menu.
