Pod::Spec.new do |s|

  s.name         = "FireMock"
  s.version      = "2.1.1"
  s.summary      = "FireMock help to build mock. Test your apps with fake response data and files."
  s.description  = "FireMock help to build mock to test your network requests with files (json, xml, etc.)."
  s.homepage     = "https://github.com/Magiic/FireMock"
  s.license      = "MIT"
  s.author       = { "Magiic" => "magiic.contact@gmail.com" }
  s.platform     = :ios, "8.0"
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"
  s.source       = { :git => 'https://github.com/Magiic/FireMock.git', :tag => s.version }
  s.source_files = "FireMock", "FireMock/**/*.{h,m, swift,xib}"
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3' }

end
