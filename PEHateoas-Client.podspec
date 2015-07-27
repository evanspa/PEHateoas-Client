Pod::Spec.new do |s|
  s.name         = "PEHateoas-Client"
  s.version      = "1.0.3"
  s.license      = "MIT"
  s.summary      = "An iOS library simplifying the consumption of hypermedia REST APIs."
  s.author       = { "Paul Evans" => "evansp2@gmail.com" }
  s.homepage     = "https://github.com/evanspa/#{s.name}"
  s.source       = { :git => "https://github.com/evanspa/#{s.name}.git", :tag => "#{s.name}-v#{s.version}" }
  s.platform     = :ios, '8.3'
  s.source_files = '**/*.{h,m}'
  s.public_header_files = '**/*.h'
  s.exclude_files = "**/*Tests/*.*"
  s.requires_arc = true
  s.dependency 'AFNetworking', '~> 2.5.4'
  s.dependency 'PEObjc-Commons', '~> 1.0.30'
  s.dependency 'CocoaLumberjack', '~> 1.9'
end
