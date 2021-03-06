# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'combi_search/version'

Gem::Specification.new do |spec|
  spec.name          = "combi_search"
  spec.version       = CombiSearch::VERSION
  spec.authors       = ["Douwe Homans"]
  spec.email         = ["douwe@avocado.nl"]

  spec.summary       = "Search in multiple models with one combined query."
  spec.description   = "Use CombiSearch to add a 'global' search to your app. For example; if you have `Book`s and `Movie`s and you want a combined search where you search in all of your titles."
  spec.homepage      = "https://github.com/douweh/combi_search"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "sqlite3", "~> 1.3"
  
  spec.add_dependency "rails", "~> 4.0"
  spec.add_dependency "search_cop"
end
