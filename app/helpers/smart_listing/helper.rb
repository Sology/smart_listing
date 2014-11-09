module SmartListing
  module Helper
    module ControllerExtensions
      def smart_listing_create options = {}
        name = (options[:name] || controller_name).to_sym
        collection = options[:collection] || smart_listing_collection

        list = SmartListing::Base.new(name, collection, options)
        list.setup(params, cookies)

        @smart_listings ||= {}
        @smart_listings[name] = list

        list.collection
      end

      def smart_listing name
        @smart_listings[name.to_sym]
      end

      def _prefixes
        super << 'smart_listing'
      end
    end

    class Builder
      # Params that should not be visible in pagination links (pages, per-page, sorting, etc.)
      UNSAFE_PARAMS = {:authenticity_token => nil, :utf8 => nil}

      class_attribute :smart_listing_helpers

      def initialize(smart_listing_name, smart_listing, template, options, proc)
        @smart_listing_name, @smart_listing, @template, @options, @proc = smart_listing_name, smart_listing, template, options, proc
      end

      def name
        @smart_listing_name
      end

      def paginate options = {}
        if @smart_listing.collection.respond_to? :current_page
          @template.paginate @smart_listing.collection, {:remote => @smart_listing.remote?, :param_name => @smart_listing.param_name(:page), :params => UNSAFE_PARAMS}.merge(@smart_listing.kaminari_options)
        end
      end

      def collection
        @smart_listing.collection
      end

      # Check if smart list is empty
      def empty?
        @smart_listing.count == 0
      end

      def pagination_per_page_links options = {}
        container_classes = [SmartListing.config.classes(:pagination_per_page)]
        container_classes << SmartListing.config.classes(:hidden) if empty?

        per_page_sizes = @smart_listing.page_sizes.clone
        per_page_sizes.push(0) if @smart_listing.unlimited_per_page?

        locals = {
          :container_classes => container_classes,
          :per_page_sizes => per_page_sizes,
        }

        @template.render(:partial => 'smart_listing/pagination_per_page_links', :locals => default_locals.merge(locals))
      end

      def pagination_per_page_link page
        if @smart_listing.per_page.to_i != page
          url = @template.url_for(sanitize_params(@template.params.merge(@smart_listing.all_params(:per_page => page, :page => 1))))
        end

        locals = {
          :page => page,
          :url => url,
        }

        @template.render(:partial => 'smart_listing/pagination_per_page_link', :locals => default_locals.merge(locals))
      end

      def sortable title, attribute, options = {}
        dirs = options[:sort_dirs] || @smart_listing.sort_dirs || [nil, "asc", "desc"]

        next_index = dirs.index(@smart_listing.sort_order(attribute)).nil? ? 0 : (dirs.index(@smart_listing.sort_order(attribute)) + 1) % dirs.length

        sort_params = {
          attribute => dirs[next_index]
        }

        locals = {
          :order => @smart_listing.sort_order(attribute),
          :url => @template.url_for(sanitize_params(@template.params.merge(@smart_listing.all_params(:sort => sort_params)))),
          :container_classes => [SmartListing.config.classes(:sortable)],
          :attribute => attribute,
          :title => title
        }

        @template.render(:partial => 'smart_listing/sortable', :locals => default_locals.merge(locals))
      end

      def update options = {}
        part = options.delete(:partial) || @smart_listing.partial || @smart_listing_name

        @template.render(:partial => 'smart_listing/update_list', :locals => {:name => @smart_listing_name, :part => part, :smart_listing => self})
      end

      # Renders the main partial (whole list)
      def render_list
        if @smart_listing.partial
          @template.render :partial => @smart_listing.partial, :locals => {:smart_listing => self}
        end
      end

      # Basic render block wrapper that adds smart_listing reference to local variables
      def render options = {}, locals = {}, &block
        if locals.empty?
          options[:locals] ||= {}
          options[:locals].merge!(:smart_listing => self)
        else
          locals.merge!({:smart_listing => self})
        end

        @template.render options, locals, &block
      end

      # Add new item button & placeholder to list
      def item_new options = {}, &block
        no_records_classes = [SmartListing.config.classes(:no_records)]
        no_records_classes << SmartListing.config.classes(:hidden) unless empty?
        new_item_button_classes = []
        new_item_button_classes << SmartListing.config.classes(:hidden) if max_count?

        locals = {
          :colspan => options.delete(:colspan),
          :no_items_classes => no_records_classes,
          :no_items_text => options.delete(:no_items_text) || @template.t("smart_listing.msgs.no_items"),
          :new_item_button_url => options.delete(:link),
          :new_item_button_classes => new_item_button_classes,
          :new_item_button_text => options.delete(:text) || @template.t("smart_listing.actions.new"),
          :new_item_autoshow => block_given?,
          :new_item_content => nil,
        }

        unless block_given?
          locals[:placeholder_classes] = [SmartListing.config.classes(:new_item_placeholder), SmartListing.config.classes(:hidden)]
          locals[:new_item_action_classes] = [SmartListing.config.classes(:new_item_action)]
          locals[:new_item_action_classes] << SmartListing.config.classes(:hidden) if !empty? && max_count?

          @template.render(:partial => 'smart_listing/item_new', :locals => default_locals.merge(locals))
        else
          locals[:placeholder_classes] = [SmartListing.config.classes(:new_item_placeholder)]
          locals[:placeholder_classes] << SmartListing.config.classes(:hidden) if !empty? && max_count?
          locals[:new_item_action_classes] = [SmartListing.config.classes(:new_item_action), SmartListing.config.classes(:hidden)]

          locals[:new_item_content] = @template.capture(&block)
          @template.render(:partial => 'smart_listing/item_new', :locals => default_locals.merge(locals))
        end
      end

      def count
        @smart_listing.count
      end

      # Check if smart list reached its item max count
      def max_count?
        return false if @smart_listing.max_count.nil?
        @smart_listing.count >= @smart_listing.max_count
      end

      private

      def sanitize_params params
        params.merge(UNSAFE_PARAMS)
      end

      def default_locals
        {:smart_listing => @smart_listing, :builder => self}
      end
    end

    # Outputs smart list container
    def smart_listing_for name, *args, &block
      raise ArgumentError, "Missing block" unless block_given?
      name = name.to_sym
      options = args.extract_options!
      bare = options.delete(:bare)

      builder = Builder.new(name, @smart_listings[name], self, options, block)

      output = ""

      data = {}
      data[SmartListing.config.data_attributes(:max_count)] = @smart_listings[name].max_count if @smart_listings[name].max_count && @smart_listings[name].max_count > 0
      data[SmartListing.config.data_attributes(:item_count)] = @smart_listings[name].count
      data[SmartListing.config.data_attributes(:href)] = @smart_listings[name].href if @smart_listings[name].href
      data[SmartListing.config.data_attributes(:callback_href)] = @smart_listings[name].callback_href if @smart_listings[name].callback_href
      data.merge!(options[:data]) if options[:data]

      if bare
        output = capture(builder, &block)
      else
        output = content_tag(:div, :class => SmartListing.config.classes(:main), :id => name, :data => data) do
          concat(content_tag(:div, "", :class => SmartListing.config.classes(:loading)))
          concat(content_tag(:div, :class => SmartListing.config.classes(:content)) do
            concat(capture(builder, &block))
          end)
        end
      end

      output
    end

    def smart_listing_render name = controller_name, *args
      smart_listing_for(name, *args) do |smart_listing|
        concat(smart_listing.render_list)
      end
    end

    def smart_listing_controls_for name, *args, &block
      smart_listing = @smart_listings.try(:[], name)

      classes = [SmartListing.config.classes(:controls), args.first.try(:[], :class)]

      form_tag(smart_listing.try(:href) || {}, :remote => smart_listing.try(:remote?) || true, :method => :get, :class => classes, :data => {SmartListing.config.data_attributes(:main) => name}) do
        concat(content_tag(:div, :style => "margin:0;padding:0;display:inline") do
          concat(hidden_field_tag("#{smart_listing.try(:base_param)}[_]", 1, :id => nil)) # this forces smart_listing_update to refresh the list
        end)
        concat(capture(&block))
      end
    end

    # Render item action buttons (ie. edit, destroy and custom ones)
    def smart_listing_item_actions actions = []
      content_tag(:span) do
        actions.each do |action|
          next unless action.is_a?(Hash)

          locals = {
            :action_if => action.has_key?(:if) ? action[:if] : true,
            :url => action.delete(:url),
            :icon => action.delete(:icon),
            :title => action.delete(:title),
          }

          template = nil
          action_name = action[:name].to_sym

          case action_name
          when :show
            locals[:icon] ||= SmartListing.config.classes(:icon_show)
            template = 'action_show'
          when :edit
            locals[:icon] ||= SmartListing.config.classes(:icon_edit)
            template = 'action_edit'
          when :destroy
            locals[:icon] ||= SmartListing.config.classes(:icon_trash)
            locals.merge!(
              :confirmation => action.delete(:confirmation),
            )
            template = 'action_delete'
          when :custom
            locals.merge!(
              :html_options => action,
            )
            template = 'action_custom'
          end

          locals[:icon] = [locals[:icon], SmartListing.config.classes(:muted)] if !locals[:action_if]

          if template
            concat(render(:partial => "smart_listing/#{template}", :locals => locals))
          else
            concat(render(:partial => "smart_listing/action_#{action_name}", :locals => {:action => action}))
          end
        end
      end
    end

    def smart_listing_limit_left name
      name = name.to_sym
      smart_listing = @smart_listings[name]

      smart_listing.max_count - smart_listing.count
    end

    #################################################################################################
    # JS helpers:

    # Updates the smart list
    def smart_listing_update options = {}
      name = (options[:name] || controller_name).to_sym
      smart_listing = @smart_listings[name]

      # don't update list if params are missing (prevents interfering with other lists)
      if params.keys.select{|k| k.include?("smart_listing")}.any? && !params[smart_listing.base_param]
        return unless options[:force]
      end

      builder = Builder.new(name, smart_listing, self, {}, nil)
      render(:partial => 'smart_listing/update_list', :locals => {
        :name => smart_listing.name,
        :part => smart_listing.partial,
        :smart_listing => builder,
        :smart_listing_data => {
          SmartListing.config.data_attributes(:params) => smart_listing.all_params,
          SmartListing.config.data_attributes(:max_count) => smart_listing.max_count,
          SmartListing.config.data_attributes(:item_count) => smart_listing.count,
        }
      })
    end

    # Renders single item (i.e for create, update actions)
    def smart_listing_item item_action, object = nil, partial = nil, options = {}
      name = (options[:name] || controller_name).to_sym
      type = object.class.name.downcase.to_sym if object
      id = options[:id] || object.try(:id)
      valid = options[:valid] if options.has_key?(:valid)
      object_key = options.delete(:object_key) || :object
      new = options.delete(:new)

      render(:partial => "smart_listing/item/#{item_action.to_s}", :locals => {:name => name, :id => id, :valid => valid, :object_key => object_key, :object => object, :part => partial, :new => new})
    end
  end
end
