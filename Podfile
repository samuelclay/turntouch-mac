# Uncomment the next line to define a global platform for your project
platform :osx, '10.10'

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
  # Sign the Sparkle helper binaries to pass App Notarization.
  system("codesign --force -o runtime -s 'Developer ID Application' Pods/Sparkle/Sparkle.framework/Resources/Autoupdate.app/Contents/MacOS/Autoupdate")
  system("codesign --force -o runtime -s 'Developer ID Application' Pods/Sparkle/Sparkle.framework/Resources/Autoupdate.app/Contents/MacOS/fileop")
end
