#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint smokerlyzer_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'smokerlyzer_flutter'
  s.version          = '0.1.0'
  s.summary          = 'Flutter plugin for Bedfont Smokerlyzer CO breathalyzers.'
  s.description      = <<-DESC
A Flutter plugin that wraps the official Bedfont Smokerlyzer SDK for iOS and Android.
Enables connecting to Smokerlyzer Bluetooth devices and collecting CO PPM readings.
                       DESC
  s.homepage         = 'https://github.com/jtperkins/smokerlyzer_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Wellcentiv' => 'dev@wellcentiv.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.vendored_frameworks = 'Frameworks/SmokerlyzerSDK.xcframework'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  # Smokerlyzer SDK doesn't have arm64 simulator slice
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.swift_version = '5.0'

  s.resource_bundles = {'smokerlyzer_flutter_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
