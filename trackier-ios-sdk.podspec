#
# Be sure to run `pod lib lint trackier-ios-sdk.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'trackier-ios-sdk'
  s.version          = '1.6.76'
  s.summary          = 'This is trackier-ios-sdk 1.6.76'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This is trackier ios SDK which is used for attribution and event tracking in iOS
                       DESC

  s.homepage         = 'https://github.com/trackier/ios-sdk'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'trackier' => 'dev@trackier.com' }
  s.source           = { :git => 'https://github.com/trackier/ios-sdk.git', :tag => '1.6.76' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.swift_version = '5.0'
  s.ios.deployment_target = '10.0'

  s.source_files = 'trackier-ios-sdk/Classes/**/*'
  
  # s.resource_bundles = {
  #   'trackier-ios-sdk' => ['trackier-ios-sdk/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'Alamofire', '~> 5.9.0'
  s.dependency 'Willow', '~> 5.0'
  s.dependency 'CryptoSwift', '~> 1.4.1'
  # s.dependency 'Networking', '~> 5.1'

end
