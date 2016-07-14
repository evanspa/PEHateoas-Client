Pod::Spec.new do |s|
  s.name         = "PEHateoas-Client"
  s.version      = "1.0.19"
  s.license      = "MIT"
  s.summary      = "An iOS library simplifying the consumption of hypermedia REST APIs."
  s.author       = { "Paul Evans" => "evansp2@gmail.com" }
  s.homepage     = "https://github.com/evanspa/#{s.name}"
  s.source       = { :git => "https://github.com/evanspa/#{s.name}.git", :tag => "#{s.name}-v#{s.version}" }
  s.requires_arc = true
  s.ios.deployment_target = '8.4'
  s.default_subspecs = 'Default'

  s.subspec 'Default' do |ss|
    ss.source_files = 'PEHateoas-Client/*.{h,m}'
    ss.exclude_files = "**/*{Test}*"
    ss.private_header_files= "PEHateoas-Client/HCLogging.h"
    ss.dependency 'AFNetworking', '~> 2.6.3'
    ss.dependency 'PEObjc-Commons', '~> 1.0.113'
    ss.dependency 'CocoaLumberjack', '~> 1.9'
  end
end
