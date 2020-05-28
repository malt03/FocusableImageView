Pod::Spec.new do |s|
  s.name             = 'FocusableImageView'
  s.version          = '0.1.0'
  s.summary          = 'FocusableImageView is a library for creating focusable imageview.'

  s.description      = <<-DESC
FocusableImageView is a library for creating focusable imageview.
Users can focus images by tapping views.
                       DESC

  s.homepage         = 'https://github.com/malt03/FocusableImageView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Koji Murata' => 'malt.koji@gmail.com' }
  s.source           = { :git => 'https://github.com/malt03/FocusableImageView.git', :tag => s.version.to_s }

  s.source_files = "Sources/**/*.swift"

  s.swift_version = "5.1"
  s.ios.deployment_target = "11.0"
end
