# Uncomment the next line to define a global platform for your project
platform :ios, '8.0'

target 'IBLNetAssistant' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!

  # Pods for IBLNetAssistant
  pod 'PCCWFoundationSwift'

  pod 'AMap3DMap'  #3D地图SDK

  pod 'AMapSearch' #搜索功能

  pod 'AMapLocation'

  pod 'PopupDialog'
  
  pod 'BaiduMobStat'

  target 'IBLNetAssistantTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'IBLNetAssistantUITests' do
    inherit! :search_paths
    # Pods for testing
  end

  post_install do |installer|
      installer.pods_project.targets.each do |target|
        swift4 = Array['CryptoSwift', 'RSKGrowingTextView', 'RSKPlaceholderTextView']
        if swift4.include? target.name then
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.0'
            end
            else
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.2'
            end
        end
      end
  end

end
