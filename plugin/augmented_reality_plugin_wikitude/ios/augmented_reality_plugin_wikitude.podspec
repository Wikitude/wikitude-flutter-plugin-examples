Pod::Spec.new do |s|
  s.name             = 'augmented_reality_plugin_wikitude'
  s.version          = '0.0.1'
  s.summary          = 'The Wikitude plugin to create augmented reality experiences in your apps.'
  s.description      = <<-DESC
The Wikitude plugin to create augmented reality experiences in your apps.
                       DESC
  s.homepage         = 'https://www.wikitude.com/'
  s.license          = { :file => '../LICENSE.md' }
  s.author           = { 'Wikitude' => 'flutter@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.vendored_frameworks = 'Frameworks/WikitudeSDK.framework'

  s.ios.deployment_target = '11.0'
end

