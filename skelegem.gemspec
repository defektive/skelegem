# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'skelegem/version'

Gem::Specification.new do |spec|
  spec.name          = "skelegem"
  spec.version       = Skelegem::VERSION
  spec.authors       = ["defektive"]
  spec.email         = ["sirbradleyd@gmail.com"]
  spec.summary       = %q{Make things easier}
  spec.description   = %q{Do it once. Set it and forget it.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "semver2", '~>3.4'
  spec.add_runtime_dependency "thor", '0.19.1'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
