Pod::Spec.new do |s|
  s.name         = "DSFColorSampler"
  s.version      = "3.0.0"
  s.summary      = "macOS color picker loupe"
  s.description  = <<-DESC
    A Swift 5 class that mimics the magnifying glass in color panel of macOS.
  DESC
  s.homepage     = "https://github.com/dagronf/DSFColorSampler"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Darren Ford" => "dford_au-reg@yahoo.com" }
  s.social_media_url   = ""
  s.osx.deployment_target = "10.13"
  s.source       = { :git => ".git", :tag => s.version.to_s }
  s.source_files  = "Sources/DSFColorSampler/DSFColorSampler.swift"
  s.frameworks  = "Cocoa"
  s.swift_version = "5.4"
end
