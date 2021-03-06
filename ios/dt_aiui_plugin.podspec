#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint dt_aiui_plugin.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'dt_aiui_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }

#  s.vendored_frameworks = "frameworks/iflyAIUI.framework"
  s.vendored_frameworks = "**/iflyAIUI.framework"

  s.frameworks = "CoreLocation","CoreTelephony","AVFoundation","AddressBook","AudioToolbox","Contacts","SystemConfiguration","QuartzCore","UIKit","Foundation","CoreGraphics"

  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.library = "z"
  
  s.libraries = "c++", "icucore", "z"

  s.resources = "resource/*"

  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
