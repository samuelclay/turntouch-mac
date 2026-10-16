# Uncomment the next line to define a global platform for your project
platform :osx, '10.13'

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
  # Set minimum deployment target for all pods
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.13'
    end
  end

  # Xcode 26 treats netinet6/in6.h as a private SDK header during module scanning.
  # netinet/in.h already provides the IPv6 socket definitions AFNetworking needs.
  [
    'Pods/AFNetworking/AFNetworking/AFHTTPSessionManager.m',
    'Pods/AFNetworking/AFNetworking/AFNetworkReachabilityManager.m',
  ].each do |path|
    text = File.read(path)
    patched = text.gsub("#import <netinet6/in6.h>\n", '')
    next if patched == text

    File.chmod(0644, path)
    File.write(path, patched)
  end

  # Sign the Sparkle helper binaries to pass App Notarization.
  system("codesign --force -o runtime -s 'Developer ID Application' Pods/Sparkle/Sparkle.framework/Resources/Autoupdate.app/Contents/MacOS/Autoupdate")
  system("codesign --force -o runtime -s 'Developer ID Application' Pods/Sparkle/Sparkle.framework/Resources/Autoupdate.app/Contents/MacOS/fileop")
end
