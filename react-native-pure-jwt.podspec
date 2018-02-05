require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name                = package['name']
  s.version             = package['version']
  s.summary             = package['description']
  s.homepage            = package['homepage']
  s.license             = package['license']
  s.author              = package['author']
  s.source              = { :git => package['repository']['url'], :tag => "v#{s.version}" }
  s.default_subspec     = 'Main'
  s.requires_arc        = true
  s.preserve_paths      = "**/*.js"

  s.subspec 'Main' do |ss|
    ss.source_files     = "ios/**/*.{h,m,swift}"
  end
end
