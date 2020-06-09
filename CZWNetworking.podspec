Pod::Spec.new do |s|
  s.name             = 'CZWNetworking'
  s.version          = '1.1.2'
  s.summary          = 'Generic Network API base on Alamofire'
  s.description      = 'tttttttttttttttttttttttttttttttttttttttt'
  s.homepage         = 'https://github.com/samzhiwei/Networking'
  # s.screenshots      = "www.example.com/screenshots_1', "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { 'Sam' => 'cenzhiwei219@gmail.com' }
  s.source           = { :git => 'https://github.com/samzhiwei/Networking.git', :tag => 'v1.1.2' }
  # s.social_media_url = 'https://twitter.com/NAME'

  s.swift_versions = '5.2'
  s.ios.deployment_target = '10.0'
  s.requires_arc = true
 
  s.source_files = 'Networking/*.swift'

  # s.resources = 'Assets'
 
  # s.ios.exclude_files = 'Classes/osx'
  # s.osx.exclude_files = 'Classes/ios'
  # s.public_header_files = 'Classes/**/*.h'
  s.frameworks = 'Foundation'
  s.dependency 'Alamofire', '5.0.5'
  s.dependency 'ReactiveCocoa', '10.2.0'
end
