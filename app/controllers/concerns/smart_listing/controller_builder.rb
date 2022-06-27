module SmartListing
  module ControllerBuilder
    private

    def smart_listing *args
      options = args.extract_options!
      name = (args[0] || options[:name] || controller_name).to_sym
      collection = args[1] || options[:collection] || (defined?(smart_listing_collection) ? smart_listing_collection : nil)

      options = {:config_profile => smart_listing_config_profile}.merge(options)

      @_smart_listings ||= {}

      base = @_smart_listings[name] ||= SmartListing::Base.new(name, collection, options).tap do |base|
        base.setup(params, cookies)
      end

      Builder.new(base, view_context, options)
    end

    def smart_listing_config_profile
      :default
    end

    def smart_listing_remote
      SmartListing::Remote::TagBuilder.new(view_context)
    end

    # TODO prepend `smart_listing` view paths
  end
end
