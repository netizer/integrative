$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "integrative/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "integrative"
  s.version     = Integrative::VERSION
  s.authors     = ["Krzysiek Herod"]
  s.email       = ["krzysiek.herod@gmail.com"]
  s.homepage    = "https://github.com/netizer/integrative"
  s.summary     = "Integrative is a library for integrating external resources into ActiveRecord models."
  s.description = "Integrative is a library for integrating external resources into ActiveRecord models."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "factory_girl"
end
