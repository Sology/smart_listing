require "rails/engine"

module SmartListing
  class Engine < Rails::Engine
    isolate_namespace SmartListing
    config.eager_load_namespaces << SmartListing
    config.smart_listing = ActiveSupport::OrderedOptions.new

    config.autoload_once_paths = %W(
      #{root}/app/controllers
      #{root}/app/controllers/concerns
      #{root}/app/helpers
      #{root}/app/lib
    )

    initializer "smart_listing.helpers", before: :load_config_initializers do
      ActiveSupport.on_load(:action_controller_base) do
        include SmartListing::ControllerBuilder
        helper SmartListing::Engine.helpers
      end
    end

    initializer "smart_listing.mimetype" do
      Mime::Type.register "text/vnd.smart-listing-remote.html", :smart_listing_remote
    end

    initializer "smart_listing.renderer" do
      ActiveSupport.on_load(:action_controller) do
        ActionController::Renderers.add :smart_listing_remote do |smart_listing_html, options|
          self.content_type = Mime[:smart_listing_remote] if media_type.nil?
          smart_listing_html
        end
      end
    end
  end
end
