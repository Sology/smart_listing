module SmartListing
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def self.banner #:nodoc:
        <<-BANNER.chomp
rails g smart_listing:install

    Copies initializer file
BANNER
      end

      desc ''
      def copy_views
        template 'initializer.rb', 'config/initializers/smart_listing.rb'
      end
    end
  end
end
