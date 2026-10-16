# Uncomment the next line to define a global platform for your project
platform :osx, '12.0'

# Ignore all warnings from all pods
inhibit_all_warnings!

target 'Turn Touch Mac' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  use_frameworks!
  pod 'AFNetworking', '~> 3.0'
  pod 'Sparkle'
  pod 'MASShortcut'
  
  # Pods for Turn Touch Mac

  target 'Turn Touch Mac Tests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
  # AFNetworking 3 predates Clang's private-header enforcement. netinet/in.h
  # already supplies the IPv6 declarations, so these private imports are obsolete.
  %w[AFHTTPSessionManager.m AFNetworkReachabilityManager.m].each do |name|
    path = "Pods/AFNetworking/AFNetworking/#{name}"
    File.chmod(0644, path)
    File.write(path, File.read(path).gsub("#import <netinet6/in6.h>\n", ""))
  end
  # Sign the Sparkle helper binaries to pass App Notarization.
  system("codesign --force -o runtime -s 'Developer ID Application' Pods/Sparkle/Sparkle.framework/Resources/Autoupdate.app/Contents/MacOS/Autoupdate")
  system("codesign --force -o runtime -s 'Developer ID Application' Pods/Sparkle/Sparkle.framework/Resources/Autoupdate.app/Contents/MacOS/fileop")
end
