$:.push File.expand_path("../lib", __FILE__)

require "smart_listing/version"

Gem::Specification.new do |spec|
  spec.name        = "smart_listing"
  spec.version     = SmartListing::VERSION
  spec.authors     = ["Sology"]
  spec.email       = ["contact@sology.eu"]
  spec.homepage    = "https://github.com/Sology/smart_listing"
  spec.description = "Ruby on Rails data listing gem with built-in sorting, filtering and in-place editing."
  spec.summary     = "SmartListing helps creating sortable lists of ActiveRecord collections with pagination, filtering and inline editing."
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage + '/blob/master/Changes.md'


  spec.add_dependency "rails", ">= 6.0"

  spec.add_development_dependency "pg"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "byebug"

  spec.add_development_dependency "capybara"
  spec.add_development_dependency "capybara-webkit"
end
