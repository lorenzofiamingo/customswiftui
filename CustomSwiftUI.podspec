Pod::Spec.new do |spec|
  spec.name             = 'CustomSwiftUI'
  spec.version          = '0.0.1'
  spec.summary          = 'CustomSwiftUI aims to complement the SwiftUI standard library.'
  spec.description      = <<-DESC
This pod contains CustomSwiftUI, a framework aiming to complement the SwiftUI standard library.
                       DESC
  spec.homepage         = 'https://github.com/wise-emotions/ios-customswiftui'
  spec.license          = { :type => 'Proprietary' }
  spec.author           = { 'iOS Team' => 'ios@telepass.com' }
  spec.source           = { :git => 'git@github.com:wise-emotions/ios-customswiftui.git', :tag => spec.version.to_s }
  spec.source_files     = [ 'Sources/CustomSwiftUI/**/*.swift' ]
  spec.resource_bundles = { 'Design' => ['Sources/CustomSwiftUI/Resources/**/*.{png,json,xib,storyboard,ttf,xcassets,strings,html,gif,jpeg,jpg,der}'] }

  spec.swift_version    = '5.7'
  spec.ios.deployment_target = '14.0'
end
