platform :osx, '10.11'

target 'Turn Touch Mac' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  use_frameworks!

  # Pods for Turn Touch Mac
  pod "CocoaAsyncSocket", "~> 7.4.3"
#  pod "AFNetworking", "~> 3.0"
  pod "SWXMLHash", "~> 3.0.0"
  pod "ReachabilitySwift", "~> 3"
  
  # SwiftyHue
  pod "SwiftyHue", :git => "https://github.com/samuelclay/SwiftyHue.git", :branch => "swift3"

  target 'Turn Touch Mac Tests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
