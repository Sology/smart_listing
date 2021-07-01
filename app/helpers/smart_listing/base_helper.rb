module SmartListing
  module BaseHelper
    def smart_listing name = controller_name, options = {}
      name = name.to_sym

      @_smart_listings ||= {}
      base = @_smart_listings[name] || SmartListing::Base.new(name, nil, options)

      Builder.new(base, self, options)
    end

    def smart_listing_dom_id *args
      SmartListing::Builder.dom_id *args
    end

    def smart_listing_controls_for name, *args, &block
      smart_listing = @_smart_listings.try(:[], name)

      classes = [smart_listing_config.classes(:controls), args.first.try(:[], :class)]

      form_tag(smart_listing.try(:href) || {}, :remote => smart_listing.try(:remote?) || true, :method => :get, :class => classes, :data => {smart_listing_config.data_attributes(:main) => name}) do
        concat(content_tag(:div, :style => "margin:0;padding:0;display:inline") do
          concat(hidden_field_tag("#{smart_listing.try(:base_param)}[_]", 1, :id => nil)) # this forces smart_listing_update to refresh the list
        end)
        concat(capture(&block))
      end
    end

    def smart_listing_limit_left name
      name = name.to_sym
      smart_listing = @smart_listings[name]

      smart_listing.max_count - smart_listing.count
    end

    #################################################################################################
    # JS helpers:

    # Updates smart listing
    #
    # Posible calls:
    # smart_listing_update name, options = {}
    # smart_listing_update options = {}
    def smart_listing_update *args
      options = args.extract_options!
      name = (args[0] || options[:name] || controller_name).to_sym
      smart_listing = @_smart_listings[name]

      # don't update list if params are missing (prevents interfering with other lists)
      if params.keys.select{|k| k.include?("smart_listing")}.present? && !params[smart_listing.base_param]
        return unless options[:force]
      end

      builder = Builder.new(name, smart_listing, self, {}, nil)
      render(:partial => 'smart_listing/update_list', :locals => {
        :name => smart_listing.name,
        :part => smart_listing.partial,
        :smart_listing => builder,
        :smart_listing_data => {
          smart_listing_config.data_attributes(:params) => smart_listing.all_params,
          smart_listing_config.data_attributes(:max_count) => smart_listing.max_count,
          smart_listing_config.data_attributes(:item_count) => smart_listing.count,
        },
        :locals => options[:locals] || {}
      })
    end

    # Renders single item (i.e for create, update actions)
    #
    # Possible calls:
    # smart_listing_item name, item_action, object = nil, partial = nil, options = {}
    # smart_listing_item item_action, object = nil, partial = nil, options = {}
    def smart_listing_item *args
      options = args.extract_options!
      if [:create, :create_continue, :destroy, :edit, :new, :remove, :update].include?(args[1])
        name = args[0]
        item_action = args[1]
        object = args[2]
        partial = args[3]
      else
        name = (options[:name] || controller_name).to_sym
        item_action = args[0]
        object = args[1]
        partial = args[2]
      end
      type = object.class.name.downcase.to_sym if object
      id = options[:id] || object.try(:id)
      valid = options[:valid] if options.has_key?(:valid)
      object_key = options.delete(:object_key) || :object
      new = options.delete(:new)

      render(:partial => "smart_listing/item/#{item_action.to_s}", :locals => {:name => name, :id => id, :valid => valid, :object_key => object_key, :object => object, :part => partial, :new => new})
    end
  end
end
