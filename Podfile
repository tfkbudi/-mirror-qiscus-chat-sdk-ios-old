# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'Example' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
#  pod 'QiscusCore'
#  pod 'QiscusRealtime', :path => '../QiscusRealtime'
  pod 'QiscusCore', :path => 'Cocoapods/'
end

target 'QiscusCore' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    pod 'SwiftyJSON'
    pod 'QiscusRealtime', '~> 0.2.0'
#    pod 'QiscusRealtime', :path => '../QiscusRealtime'
end

target 'QiscusCoreTests' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    pod 'Quick'
    pod 'Nimble'
end
