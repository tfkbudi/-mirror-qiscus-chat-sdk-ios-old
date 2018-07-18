Pod::Spec.new do |s|

s.name         = "QiscusCore"
s.version      = "2.8.0"
s.summary      = "Qiscus Core SDK for iOS"

s.description  = <<-DESC
Qiscus SDK for iOS contains Qiscus public Model.
DESC

s.homepage     = "https://qisc.us"

s.license      = "MIT"
s.author       = "Qiscus"

s.source       = { :git => "https://github.com/qiscus/qiscus-sdk-ios.git", :tag => "#{s.version}" }


s.source_files  = "QiscusCore/**/*.{swift}"
s.resource_bundles = {
    'QiscusCore' => ['QiscusCore/**/*.{json,strings}']
}

s.platform      = :ios, "9.0"

s.dependency 'RealmSwift', '~> 3.0.2'
s.dependency 'SwiftyJSON', '~> 3.1.4'
s.dependency 'CocoaMQTT', '1.1.1'

end
