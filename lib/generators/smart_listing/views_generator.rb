module SmartListing
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      source_root File.expand_path('../../../../app/views/smart_listing', __FILE__)

      def self.banner #:nodoc:
        <<-BANNER.chomp
rails g smart_listing:views

    Copies all smart listing partials templates to your application.
BANNER
      end

      desc ''
      def copy_views
        filename_pattern = File.join self.class.source_root, "*.html.erb"
        Dir.glob(filename_pattern).map {|f| File.basename f}.each do |f|
          copy_file f, "app/views/smart_listing/#{f}"
        end
      end
    end
  end
end
