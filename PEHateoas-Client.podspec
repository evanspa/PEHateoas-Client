Pod::Spec.new do |s|
  s.name         = "PEHateoas-Client"
  s.version      = "1.0.19"
  s.license      = "MIT"
  s.summary      = "An iOS library simplifying the consumption of hypermedia REST APIs."
  s.author       = { "Paul Evans" => "evansp2@gmail.com" }
  s.homepage     = "https://github.com/evanspa/#{s.name}"
  s.source       = { :git => "https://github.com/evanspa/#{s.name}.git", :tag => "#{s.name}-v#{s.version}" }
  s.platform     = :ios, '8.4'
  s.source_files = 'PEHateoas-Client/*.{h,m}'
  s.private_header_files= "**/HCLogging.h"
  s.exclude_files = "**/*{Test}*"
  s.requires_arc = true
  s.dependency 'AFNetworking', '~> 2.6.3'
  s.dependency 'PEObjc-Commons', '~> 1.0.112'
  s.dependency 'CocoaLumberjack', '~> 1.9'
end
