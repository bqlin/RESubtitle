Pod::Spec.new do |s|

  s.name         = "RESubtitle"
  s.version      = "0.1.0"
  s.summary      = "SRT 字幕解析组件，字幕显示组件。"
  s.description  = <<-DESC
  RESubtitle
  字幕解析组件，字幕显示组件。
                   DESC
  s.homepage     = "https://github.com/bqlin/RESubtitle"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "bqlin" => "bqlins@163.com" }

  s.source       = { :git => "https://github.com/bqlin/RESubtitle.git", :tag => "#{s.version}" }
  s.source_files  = "RESubtitle/**/*.{h,m}"
  s.requires_arc = true
  s.platform     = :ios, "8.0"

end
