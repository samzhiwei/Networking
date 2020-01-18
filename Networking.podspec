Pod::Spec.new do |s|
  s.name             = "Networking"
  s.version          = "1.0.0"
  s.summary          = "Generic Network API base on Alamofire"
  #s.description
  s.homepage         = "https://github.com/samzhiwei/Networking"
  # s.screenshots      = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Sam" => "cenzhiwei219@gmail.com" }
  s.source           = { :git => "https://github.com/samzhiwei/Networking.git" }
  # s.social_media_url = 'https://twitter.com/NAME'
 
  s.platform     = :ios, '10.0'
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'
  s.requires_arc = true
 
  #s.source_files = 'WZMarqueeView/*'
  # s.resources = 'Assets'
 
  # s.ios.exclude_files = 'Classes/osx'
  # s.osx.exclude_files = 'Classes/ios'
  # s.public_header_files = 'Classes/**/*.h'
  s.frameworks = 'Foundation', 'CoreGraphics', 'UIKit'
  s.dependency "Alamofire", "5.0.0-rc.3"
end
