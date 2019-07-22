# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 's3_thumbnail/version'

Gem::Specification.new do |spec|
  spec.name          = "s3_thumbnail"
  spec.version       = S3Thumbnail::VERSION
  spec.authors       = ["Jeremy Saenz"]
  spec.email         = ["jeremy.saenz@gmail.com"]

  spec.summary       = %q{Easy image thumbnails for the s3direct gem}
  spec.description   = %q{s3_thumbnail will generate thumbnails for s3direct files}
  spec.homepage      = "http://github.com/codegangsta/s3_thumbnail"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'mini_magick', '~> 3.7'
  spec.add_dependency 'activesupport', '>= 3.2.0'
  spec.add_dependency 's3_style', '>= 0.1.0'
  spec.add_dependency "s3direct", '>= 0.1.0'

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "aws-sdk", "~> 1.36.0"
  spec.add_development_dependency "fakes3", "~> 0.2.1"
  spec.add_development_dependency "activemodel"
end
