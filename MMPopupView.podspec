Pod::Spec.new do |s|
  s.name         = "MMPopupView"
  s.version      = "1.7.7"
  s.summary      = "Pop-up based view(e.g. AlertView SheetView), or you can easily customize for your own usage."
  s.homepage     = "https://github.com/gaizhi/MMPopupView"
  s.license      = { :type => 'MIT License', :file => 'LICENSE' }
  s.author       = { "gaizhi" => "job.xuqiang@icloud.com" }
  s.source       = { :git => "https://github.com/gaizhi/MMPopupView.git", :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.frameworks = [
    'UIKit'
  ]
  s.dependency 'Masonry'
  s.default_subspec = 'Core'

  s.subspec 'Core' do |c|
    c.source_files = 'Classes/*.{h,m}'
  end

  s.subspec 'Comp' do |cp|
    cp.source_files = 'Components/*.{h,m}'
    cp.dependency 'MMPopupView/Core'
  end

end
