Pod::Spec.new do |s|
  s.name             = "BEACONinsideSDK"
  s.version          = "1.0.0-beta1"
  s.summary          = "iOS library for working with iBeacons."
  s.description      = <<-DESC
                       The BEACONinside SDK makes it extremely simple to integrate
                       iBeacon support into your iOS app.
                       
                       It works best with iBeacons from BEACONinside, but also
                       supports beacons from other manufacturers.
                       DESC
  s.homepage         = "http://www.beaconinside.com/"
  s.license          = "MIT"
  s.author           = "BEACONinside"
  s.source           = { :git => "https://github.com/beaconinside/BEACONinside-SDK-iOS.git", :tag => s.version.to_s }
  s.social_media_url = "https://twitter.com/beaconinside"

  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '6.0'
  s.requires_arc = true

  s.vendored_library = "lib/libBEACONinsideSDK.a"
  s.public_header_files = 'include/**/*.h'
  s.frameworks = 'Foundation', 'CoreLocation', 'CoreBluetooth'
end
