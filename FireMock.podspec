Pod::Spec.new do |s|

  s.name         = "FireMock"
  s.version      = "3.1"
  s.summary      = "FireMock help to stub HTTP requests. Test your apps with fake response data and files."
  s.description  = "FireMock help to build mock to test your network requests with files (json, xml, etc.). With 2 simple steps, you can enable/disable a specific mock on runtime. Change mock file on runtime with a specific view build for this purpose."
  s.homepage     = "https://github.com/Magiic/FireMock"
  s.license      = "MIT"
  s.author       = { "Magiic" => "magiic.contact@gmail.com" }
  s.platform     = :ios, "9.0"
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"
  s.source       = { :git => 'https://github.com/Magiic/FireMock.git', :tag => s.version }
  s.source_files = "FireMock", "FireMock/**/*.{h,m, swift,xib}"
  s.resources = ['FireMock.xcassets']
  #s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4' }

end
