Pod::Spec.new do |s|
  s.name         = "DSFColorPickerLoupe"
  s.version      = "1.0"
  s.summary      = "macOS color picker loupe"
  s.description  = <<-DESC
    A Swift 4 class that mimics the magnifying glass in color panel of macos.
  DESC
  s.homepage     = "https://github.com/dagronf/DSFColorPickerLoupe"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Darren Ford" => "dford_au-reg@yahoo.com" }
  s.social_media_url   = ""
  s.osx.deployment_target = "10.10"
  s.source       = { :git => ".git", :tag => s.version.to_s }
  s.source_files  = "DSFColorPickerLoupe/DSFColorPickerLoupe.swift"
  s.frameworks  = "Cocoa"
  s.swift_version = "5.0"
end
