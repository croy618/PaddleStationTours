# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'





target 'Paddle Station' do
 	# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
  	inhibit_all_warnings!

  	# Pods for Paddle Station
	pod 'AFNetworking', '~> 3.0'
	pod 'R.swift'
	pod 'SegueManager'
	pod 'SegueManager/R.swift'
	pod 'Sluthware', :git => 'https://patsluth@bitbucket.org/patsluth/sluthware-swift.git'
	pod 'Reveal-SDK', :configurations => ['Debug']
	pod 'Alertift'
	pod 'SwiftNotificationCenter'
	pod 'HLSpriteKit', '~> 1.0'

end





post_install do |installer_representation|
	installer_representation.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['GCC_WARN_ABOUT_DEPRECATED_FUNCTIONS'] = 'NO'
			config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
			config.build_settings['ENABLE_BITCODE'] = 'YES'
			config.build_settings['SWIFT_VERSION'] = '4.0'
		end
	end
end




