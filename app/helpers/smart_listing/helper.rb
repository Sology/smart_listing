module SmartListing
  module Helper
    module ControllerExtensions
      def smart_listing_create name, collection, options = {}
        name = name.to_sym

        list = SmartListing::Base.new(name, collection, options)
        list.setup(params, cookies)

        @smart_listings ||= {}
        @smart_listings[name] = list

        list.collection
      end

      def smart_listing name
        @smart_listings[name.to_sym]
      end
    end

    class Builder
      # Params that should not be visible in pagination links (pages, per-page, sorting, etc.)
      UNSAFE_PARAMS = {:authenticity_token => nil, :utf8 => nil}

      class_attribute :smart_listing_helpers

      def initialize(smart_listing_name, smart_listing, template, options, proc)
        @smart_listing_name, @smart_listing, @template, @options, @proc = smart_listing_name, smart_listing, template, options, proc
      end

      def paginate options = {}
        if @smart_listing.collection.respond_to? :current_page
          @template.paginate @smart_listing.collection, :remote => true, :param_name => @smart_listing.param_names[:page], :params => UNSAFE_PARAMS
        end
      end

      def collection
        @smart_listing.collection
      end

      def pagination_per_page_links options = {}
        container_classes = ["pagination_per_page"]
        container_classes << "disabled" if empty?

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
          url = @template.url_for(sanitize_params(@template.params.merge(@smart_listing.param_names[:per_page] => page, @smart_listing.param_names[:page] => 1)))
        end

        locals = {
          :page => page, 
          :url => url,
        }

        @template.render(:partial => 'smart_listing/pagination_per_page_link', :locals => default_locals.merge(locals))
      end

      def sortable title, attribute, options = {}
        extra = options.delete(:extra)

        sort_params = {
          @smart_listing.param_names[:sort_attr] => attribute, 
          @smart_listing.param_names[:sort_order] => (@smart_listing.sort_order == "asc") ? "desc" : "asc", 
          @smart_listing.param_names[:sort_extra] => extra
        }

        locals = {
          :ordered => @smart_listing.sort_attr == attribute && (!@smart_listing.sort_extra || @smart_listing.sort_extra == extra.to_s),
          :url => @template.url_for(sanitize_params(@template.params.merge(sort_params))),
          :container_classes => ["sortable"],
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
      def item_new options = {}
        new_item_action_classes = %{new_item_action} 
        new_item_action_classes << "disabled" if !empty? && max_count?
        no_records_classes = %{no_records}
        no_records_classes << "disabled" unless empty?
        new_item_button_classes = []
        new_item_button_classes << "disabled" if max_count?

        locals = {
          :placeholder_classes => %w{new_item_placeholder disabled},
          :new_item_action_classes => new_item_action_classes,
          :colspan => options.delete(:colspan),
          :no_items_classes => no_records_classes,
          :no_items_text => options.delete(:no_items_text),
          :new_item_button_url => options.delete(:link),
          :new_item_button_classes => new_item_button_classes,
          :new_item_button_text => options.delete(:text),
        }

        @template.render(:partial => 'smart_listing/item_new', :locals => default_locals.merge(locals))
        nil
      end

      # Check if smart list is empty
      def empty?
        @smart_listing.count == 0
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
      data['max-count'] = @smart_listings[name].max_count if @smart_listings[name].max_count && @smart_listings[name].max_count > 0
      data['href'] = @smart_listings[name].href if @smart_listings[name].href

      if bare
        output = capture(builder, &block)
      else
        output = content_tag(:div, :class => "smart_listing", :id => name, :data => data) do
          concat(content_tag(:div, "", :class => "loading"))
          concat(content_tag(:div, :class => "content") do
            concat(capture(builder, &block))
          end)
        end
      end

      output
    end

    # Render item action buttons (ie. edit, destroy and custom ones)
    def smart_listing_item_actions actions = []
      content_tag(:span) do
        actions.each do |action|
          next unless action.is_a?(Hash)

          if action.has_key?(:if)
            unless action[:if]
              concat(render(:partial => 'smart_listing/action_inactive'))
              next
            end
          end

          action_name = action[:name].to_sym
          case action_name
          when :edit
            locals = {
              :url => action.delete(:url),
              :icon => action.delete(:icon),
            }
						concat(render(:partial => 'smart_listing/action_edit', :locals => locals))
          when :destroy
            locals = {
              :url => action.delete(:url),
              :icon => action.delete(:icon),
              :confirmation => action.delete(:confirmation),
            }
						concat(render(:partial => 'smart_listing/action_delete', :locals => locals))
          when :custom
            locals = {
              :url => nil,
              :icon => nil,
              :html_options => nil,
            }.merge(action)
						concat(render(:partial => 'smart_listing/action_custom', :locals => locals))
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
    def smart_listing_update name
      name = name.to_sym
      smart_listing = @smart_listings[name]
      builder = Builder.new(name, smart_listing, self, {}, nil)
      render(:partial => 'smart_listing/update_list', :locals => {
        :name => smart_listing.name, 
        :part => smart_listing.partial, 
        :smart_listing => builder, 
        :smart_listing_data => {
          :params => smart_listing.all_params,
          'max-count' => smart_listing.max_count,
        }
      })
    end

    # Renders single item (i.e for create, update actions)
    def smart_listing_item name, item_action, object = nil, partial = nil, options = {}
      name = name.to_sym
      type = object.class.name.downcase.to_sym if object
      id = options[:id] || object.try(:id)
      valid = options[:valid] if options.has_key?(:valid)
      object_key = options.delete(:object_key) || :object

      render(:partial => "smart_listing/item/#{item_action.to_s}", :locals => {:name => name, :id => id, :valid => valid, :object_key => object_key, :object => object, :part => partial})
    end
  end
end
