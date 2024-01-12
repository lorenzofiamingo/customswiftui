import ProjectDescription

// MARK: - File Header Template

let fileHeaderTemplate: FileHeaderTemplate = """
  //
  // CustomSwiftUI Demo
  //
  """

// MARK: - Project Options

let options = Project.Options.options(
  developmentRegion: "it"
)

// MARK: - Demo Target

let demoTarget = Target(
  name: "Demo",
  platform: .iOS,
  product: .app,
  bundleId: "com.telepass.customswiftui.demo",
  deploymentTarget: .iOS(targetVersion: "16.0", devices: [.iphone, .ipad]),
  infoPlist: nil,
  sources: ["Demo/**"],
  dependencies: [
    .package(product: "CustomSwiftUI"),
    .package(product: "swift-format"),
    .package(product: "SwiftFormat"),
  ],
  settings: .settings(
    base: [
      "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
      "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
      "CODE_SIGN_STYLE": "Automatic",
      "CURRENT_PROJECT_VERSION": "1.0",
      "DEVELOPMENT_ASSET_PATHS": "\"Demo/Preview Content\"",
      "DEVELOPMENT_TEAM": "XKET3Q5DFE",
      "ENABLE_PREVIEWS": true,
      "GENERATE_INFOPLIST_FILE": true,
      "INFOPLIST_KEY_UIApplicationSceneManifest_Generation": true,
      "INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents": true,
      "INFOPLIST_KEY_UILaunchScreen_Generation": true,
      "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad": [
        "UIInterfaceOrientationPortrait",
        "UIInterfaceOrientationPortraitUpsideDown",
        "UIInterfaceOrientationLandscapeLeft",
        "UIInterfaceOrientationLandscapeRight",
      ],
      "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone": [
        "UIInterfaceOrientationPortrait",
        "UIInterfaceOrientationLandscapeLeft",
        "UIInterfaceOrientationLandscapeRight",
      ],
      "LD_RUNPATH_SEARCH_PATHS": [
        "$(inherited)",
        "@executable_path/Frameworks",
      ],
      "MARKETING_VERSION": "1.0",
      "PRODUCT_BUNDLE_IDENTIFIER": "com.telepass.customswiftui.demo",
      "PRODUCT_NAME": "$(TARGET_NAME)",
      "SWIFT_EMIT_LOC_STRINGS": true,
      "SWIFT_VERSION": "5.0",
      "TARGETED_DEVICE_FAMILY": "1,2",
    ],
    defaultSettings: .none
  )
)

// MARK: - Project

let project = Project(
  name: "CustomSwiftUI",
  organizationName: "com.telepass",
  options: options,
  packages: [
    .local(path: "./.."),
    .remote(
      url: "https://github.com/apple/swift-format", requirement: .upToNextMajor(from: "509.0.0")),
  ],
  targets: [
    demoTarget
  ],
  fileHeaderTemplate: fileHeaderTemplate
)
