Pod::Spec.new do |spec|
  spec.name             = 'CustomSwiftUI'
  spec.version          = ENV['LIB_VERSION'] || '1.0'
  spec.license          = { :type => 'MIT' }
  spec.homepage         = 'https://github.com/lorenzofiamingo/customswiftui'
  spec.authors          = { 'Lorenzo Fiamingo' => 'l99fiamingo@gmail.com' }
  spec.summary          = 'CustomSwiftUI aims to complement the SwiftUI standard library.'
  spec.source           = { :git => 'https://github.com/lorenzofiamingo/customswiftui', :tag => spec.version.to_s }
  spec.source_files     = [ 'Sources/**/*.swift' ]
end
