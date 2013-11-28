$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "smart_listing/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "smart_listing"
  s.version     = SmartListing::VERSION
  s.authors     = ["Sology"]
  s.email       = ["contact@sology.eu"]
  s.homepage    = "http://www.sology.eu"
  s.summary     = "Summary of SmartList."
  s.description = "Description of SmartList."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">=3.2"
	s.add_dependency "coffee-rails"
	s.add_dependency "kaminari"
	
	s.add_development_dependency "sqlite3"

end
