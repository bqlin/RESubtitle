Pod::Spec.new do |s|

  s.name         = "PLVSubtitle"
  s.version      = "0.0.3"
  s.summary      = "SRT 字幕解析组件，字幕显示组件。"
  s.description  = <<-DESC
  PLVSubtitle
  SRT 字幕解析组件，字幕显示组件。
                   DESC
  s.homepage     = "https://github.com/bqlin/BqSubtitle"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "bqlin" => "bqlins@163.com" }

  s.source       = { :git => "https://github.com/bqlin/BqSubtitle.git", :tag => "#{s.version}" }
  s.source_files  = "PLVSubtitle/**/*.{h,m}"
  s.requires_arc = true
  s.platform     = :ios, "8.0"

end
