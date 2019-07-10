# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'Example' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'QiscusCore', :path => '.'
  #pod 'QiscusRealtime', '~> 0.3.0'
  #pod 'QiscusRealtime', :path => '../QiscusRealtime'
  #pod 'QiscusRealtime', :path => '../QiscusRealtime/Cocoapods/'
  pod 'QiscusRealtime',  :git => 'https://github.com/qiscus/QiscusRealtime-iOS.git', :tag => '0.4.0-beta1'
end

target 'QiscusCore' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    pod 'SwiftyJSON'
    #pod 'QiscusRealtime', '~> 0.3.0'
    #pod 'QiscusRealtime', :path => '../QiscusRealtime/Cocoapods/'
    pod 'QiscusRealtime',  :git => 'https://github.com/qiscus/QiscusRealtime-iOS.git', :tag => '0.4.0-beta1'
end

target 'QiscusCoreTests' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    pod 'Quick'
    pod 'Nimble'
end
