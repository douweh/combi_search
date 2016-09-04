# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'combi_search/version'

Gem::Specification.new do |spec|
  spec.name          = "combi_search"
  spec.version       = CombiSearch::VERSION
  spec.authors       = ["Douwe Homans"]
  spec.email         = ["douwe@avocado.nl"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.summary       = "Adds a search index which combines multiple ActiveRecord models"
  spec.description   = "CombiSearch allows you to combine multiple ActiveRecord models in a search query. You are able to specify which attributes will be searchable per model, and search will returen search 'Entry'-entities which'll include the original ActiveRecord models as a related model."
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"

  spec.add_dependency "rails", "~> 4.0"
end
