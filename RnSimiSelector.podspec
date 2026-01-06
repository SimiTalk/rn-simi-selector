require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "RnSimiSelector"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => min_ios_version_supported }
  s.source       = { :git => "https://github.com/SimiTalk/rn-simi-selector.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm,swift,cpp}"
  s.private_header_files = "ios/**/*.h"

  s.dependency "ZLPhotoBrowser"

  # Bundle 命名，暂时没有资源类用到
  s.resource_bundles = {
    'RnSimiSelector' => ['ios/Assets/**/*']
  }

  install_modules_dependencies(s)

  # 4. 关键配置：针对混合编译（Swift + Objective-C++）
  s.pod_target_xcconfig = {
    "CLANG_CXX_LANGUAGE_STANDARD" => "c++20", # RN 0.78 标准
    "DEFINES_MODULE" => "YES",
    "SWIFT_COMPILATION_MODE" => "wholemodule"
  }
  
  s.swift_version = "5.0"
end
