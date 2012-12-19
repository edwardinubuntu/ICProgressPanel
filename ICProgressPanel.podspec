Pod::Spec.new do |s|
  s.name     = 'ICProgressPanel'
  s.version  = '0.1.1'
  s.license      = 'MIT'
  s.summary  = 'A panel displaying the current status, including uploading, cancel if needed, waiting response, and upload finish.'
  s.homepage = 'https://github.com/edwardinubuntu/ICProgressPanel'
  s.author  =  'Edward Chiang'
  s.platform     = :ios, '5.0'
  s.source   = { :git => 'https://github.com/edwardinubuntu/ICProgressPanel.git', :tag => 'v0.1.1'}
  s.source_files = 'ICProgressPanel/ProgressPanel'
  s.resources = 'ICProgressPanel/Images'
  s.requires_arc = true
  s.framework = 'QuartzCore'
  s.dependency 'BlocksKit'
end
