Pod::Spec.new do |s|
  s.name             = 'Networking'
  s.version          = '1.0.0'
  s.summary          = 'Generic Network API base on Alamofire'
  s.description      = 'yes'
  s.homepage         = 'https://github.com/samzhiwei/Networking'
  # s.screenshots      = "www.example.com/screenshots_1', "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { 'Sam' => 'cenzhiwei219@gmail.com' }
  s.source           = { :git => 'https://github.com/samzhiwei/Networking.git' }
  # s.social_media_url = 'https://twitter.com/NAME'
 
  s.ios.deployment_target = '10.0'
  s.requires_arc = true
 
  s.source_files = 'Networking/*.swift'
  # s.resources = 'Assets'
 
  # s.ios.exclude_files = 'Classes/osx'
  # s.osx.exclude_files = 'Classes/ios'
  # s.public_header_files = 'Classes/**/*.h'
  s.frameworks = 'Foundation'
  s.dependency 'Alamofire', '~> 5.0.2'
  s.dependency 'ReactiveCocoa', '~> 10.2.0'
end
