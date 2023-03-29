[![Deploy To CocoaPods](https://github.com/lorenzofiamingo/customswiftui/actions/workflows/deploy_to_cocoapods.yml/badge.svg)](https://github.com/lorenzofiamingo/customswiftui/actions/workflows/deploy_to_cocoapods.yml)

# CustomSwiftUI

CustomSwiftUI aims to complement the SwiftUI standard library. 

## When to resort to CustomSwiftUI

CustomSwiftUI should cover those cases:
- A certain SwiftUI API is not public
- A certain SwiftUI API is not available in old OSes
- A certain UIKit API is not available in SwiftUI

## Contents

### View fundamentals
- [x] `CustomView`
: Use `CustomView` replacing `body` with `customBody` if you want the body of the `View` to be exposed to the `CustomViewBuilder`.
- [x] `CustomViewBuilder`
: `CustomViewBuilder` makes possible to inspect the view tree hierarchy (until a `ViewBuilder` is encountered).
- [x] `customTag`

### Lists
- [x] `CustomForEach`

### Controls and indicators
- [x] `CustomPicker`
: `CustomPicker` makes possible to implement picker style via `CustomPickerStyle` and polyfills the creation of picker from a collection.

## Design

The purpose of CustomSwiftUI is to extend the SwiftUI library by ensuring the greatest possible consistency with it, so the APIs of the two libraries have to match as much as possible.

### Naming convention

In order to avoid collisions, ensure API discovery, and make clear in code the usage of CustomSwiftUI APIs, all top-level structures and methods in SwiftUI API extensions must begin with `Custom`.
For example, to polyfill `ColorPicker` back to older OSes, `CustomColorPicker` should be created.
