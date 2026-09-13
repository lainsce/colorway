<img align="left" style="vertical-align: middle" width="128" height="128" src="data/Colorway.icon/Assets/Colorway.png">

# Colorway

Explore color relationships with a focused native color picker

###

## 💝 Donations

Would you like to support the development of this app to new heights?
Then become a GitHub Sponsor or check my Patreon, buttons in the sidebar.

## 🛠️ Dependencies

Please make sure you have these dependencies first before building.
```text
xcode 27
swift 5
macOS 27 SDK
```

## ✨ Highlights

- Pick colors from a saturation/brightness surface and hue rail
- Sample a color anywhere on screen with the native macOS sampler
- Enter exact HEX values and copy any selected or harmony swatch
- Explore complementary, analogous, triadic, tetradic, and monochrome palettes
- Keep every color local with no account or network service

## 🏗️ Building

Clone this repo, then build the unsigned macOS app:
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

Open `Colorway.xcodeproj` in Xcode to run the app or its tests.
