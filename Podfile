# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'simple-quran' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for simple-quran
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Messaging'
  pod 'Action'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxDataSources'
  pod 'Toast-Swift', '~> 4.0.0'
  pod 'Shimmer', :git => 'https://github.com/hasifofficial/Shimmer'

  target 'simple-quranTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'simple-quranUITests' do
    # Pods for testing
  end
  
  post_install do |installer|
    installer.generated_projects.each do |project|
      project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
           end
      end
    end
  end
end
