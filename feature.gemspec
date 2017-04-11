$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "feature/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "feature"
  s.version     = Feature::VERSION
  s.authors     = ["Federico Tagliabue"]
  s.email       = ["fede.tagliabue@gmail.com"]
  s.homepage    = "https://github.com/fedetaglia/i-will-do-this/"
  s.summary     = "Wrapper with default fallout and web dashboard for rollout gem."
  s.description = "Wrapper with default fallout and web dashboard for rollout gem."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.0", ">= 5.0.0.1"
  s.add_dependency "rollout"
  s.add_dependency "slim"
  s.add_dependency "jquery-rails"
  s.add_dependency "bootstrap-sass"

  s.add_development_dependency "sqlite3"
end
