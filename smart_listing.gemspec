$:.push File.expand_path("../lib", __FILE__)

require "smart_listing/version"

Gem::Specification.new do |s|
  s.name        = "smart_listing"
  s.version     = SmartListing::VERSION
  s.authors     = ["Sology"]
  s.email       = ["contact@sology.eu"]
  s.homepage    = "https://github.com/Sology/smart_listing"
  s.summary     = "SmartListing helps creating sortable lists of ActiveRecord collections with pagination, filtering and inline editing."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">=3.2"
	s.add_dependency "coffee-rails"
	s.add_dependency "kaminari"
	
	s.add_development_dependency "sqlite3"

end
