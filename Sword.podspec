Pod::Spec.new do |s|
  s.name             = 'Sword'
  s.version          = '0.9.0'
  s.summary          = 'A Discord Library for Swift'
  s.homepage         = 'https://github.com/Azoy/Sword'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = 'Azoy'
  s.source           = { :git => 'https://github.com/Azoy/Sword.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
  s.pod_target_xcconfig = {
    'SWIFT_VERSION' => '4.0.0'
  }

  s.source_files = 'Sources/Sword/*.swift',
                   'Sources/Sword/Gateway/*.swift',
                   'Sources/Sword/Rest/*.swift',
                   'Sources/Sword/Shield/*.swift',
                   'Sources/Sword/Types/*.swift',
                   'Sources/Sword/Utils/*.swift'
  s.dependency 'Starscream', '~> 3.0'
end
