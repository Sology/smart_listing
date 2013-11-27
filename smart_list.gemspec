$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "smart_list/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "smart_list"
  s.version     = SmartList::VERSION
  s.authors     = ["Sology"]
  s.email       = ["lukasz@sology.eu"]
  s.homepage    = "http://sology.eu"
  s.summary     = "Summary of SmartList."
  s.description = "Description of SmartList."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", ">=3.2"
	s.add_dependency "coffee-rails"
	s.add_dependency "kaminari"
	
	s.add_development_dependency "sqlite3"

end
