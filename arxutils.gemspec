# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arxutils/version'

Gem::Specification.new do |spec|
  spec.name          = "arxutils"
  spec.version       = Arxutils::VERSION
  spec.authors       = ["yasuo kominami"]
  spec.email         = ["ykominami@gmail.com"]

  spec.summary       = %q{utility functions for ActiveRecord.}
  spec.description   = %q{utility functions for ActiveRecord.}
  spec.homepage      = ""

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
#    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
#  spec.files         =  `find .`.split 
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

#  spec.add_runtime_dependency "activesupport"
#  spec.add_runtime_dependency "erb"
# spec.add_runtime_dependency "activerecord" , "~> 7.0.2.3"
  #spec.add_runtime_dependency "sqlite3"
  #spec.add_runtime_dependency "mysql2" , "~> 0.4.1"
  spec.add_runtime_dependency "mysql2"
  spec.add_runtime_dependency "encx"
  spec.add_runtime_dependency "simpleoptparse"

  # spec.add_development_dependency "bundler", "~> 2.3.7"
  # spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
end
