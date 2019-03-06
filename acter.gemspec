lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "acter/version"

Gem::Specification.new do |spec|
  spec.name          = "acter"
  spec.version       = Acter::VERSION
  spec.authors       = ["Ben Slusky"]
  spec.email         = ["bslusky@smartling.com"]

  spec.summary       = "Command line client for APIs described by JSON Schema"
  spec.homepage      = "https://github.com/syskill/acter"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "prmd", "~> 0.13"
  spec.add_dependency "faraday", "~> 0.15"
  spec.add_dependency "faraday_middleware", "~> 0.13"
  spec.add_dependency "rouge", "~> 1.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
