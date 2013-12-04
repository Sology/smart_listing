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
        @template.content_tag(:div, :class => "pagination_per_page #{'disabled' if empty?}") do
          if @smart_listing.count > SmartListing::Base::PAGE_SIZES.first
            @template.concat(@template.t('views.pagination.per_page'))
            per_page_sizes = SmartListing::Base::PAGE_SIZES.clone
            per_page_sizes.push(0) if @smart_listing.unlimited_per_page?
            per_page_sizes.each do |p|
              name = p == 0 ? @template.t('views.pagination.unlimited') : p
              if @smart_listing.per_page.to_i != p
                @template.concat(@template.link_to(name, @template.url_for(sanitize_params(@template.params.merge(@smart_listing.param_names[:per_page] => p, @smart_listing.param_names[:page] => 1))), :remote => true))
              else 
                @template.concat(@template.content_tag(:span, name))
              end
              break if p > @smart_listing.count
            end
            @template.concat ' | '
          end if @smart_listing.options[:paginate]
          @template.concat(@template.t('views.pagination.total'))
          @template.concat(@template.content_tag(:span, @smart_listing.count, :class => "count"))
        end
      end

      def sortable title, attribute, options = {}
        extra = options.delete(:extra)

        sort_params = {
          @smart_listing.param_names[:sort_attr] => attribute, 
          @smart_listing.param_names[:sort_order] => (@smart_listing.sort_order == "asc") ? "desc" : "asc", 
          @smart_listing.param_names[:sort_extra] => extra
        }

        @template.link_to(@template.url_for(sanitize_params(@template.params.merge(sort_params))), :class => "sortable", :data => {:attr => attribute}, :remote => true) do
          @template.concat(title)
          if @smart_listing.sort_attr == attribute && (!@smart_listing.sort_extra || @smart_listing.sort_extra == extra.to_s)
            @template.concat(@template.content_tag(:span, "", :class => (@smart_listing.sort_order == "asc" ? "glyphicon glyphicon-chevron-up" : "glyphicon glyphicon-chevron-down"))) 
          else
            @template.concat(@template.content_tag(:span, "", :class => "glyphicon glyphicon-resize-vertical"))
          end
        end
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
        @template.concat(@template.content_tag(:tr, '', :class => "info new_item_placeholder disabled"))
        @template.concat(@template.content_tag(:tr, :class => "info new_item_action #{'disabled' if !empty? && max_count?}") do
          @template.concat(@template.content_tag(:td, :colspan => options.delete(:colspan)) do
            @template.concat(@template.content_tag(:p, :class => "no_records pull-left #{'disabled' unless empty?}") do
              @template.concat(options.delete(:no_items_text))
            end)
            @template.concat(@template.link_to(options.delete(:link), :remote => true, :class => "btn pull-right #{'disabled' if max_count?}") do
              @template.concat(@template.content_tag(:i, '', :class => "glyphicon glyphicon-plus"))
              @template.concat(" ")
              @template.concat(options.delete(:text))
            end)
          end)
        end)
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
    end

    # Outputs smart list container
    def smart_listing_for name, *args, &block
      raise ArgumentError, "Missing block" unless block_given?
      name = name.to_sym
      options = args.extract_options!
      bare = options.delete(:bare)

      builder = Builder.new(name, @smart_listings[name], self, options, block)

      output =""

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
              concat(content_tag(:i, '', :class => "glyphicon glyphicon-remove-circle"))
              next
            end
          end

          case action.delete(:name).to_sym
          when :edit
            url = action.delete(:url)
            html_options = {
              :remote => true, 
              :class => "edit",
              :title => t("smart_listing.actions.edit")
            }.merge(action)

            concat(link_to(url, html_options) do
              concat(content_tag(:i, '', :class => "glyphicon glyphicon-pencil"))
            end)
          when :destroy
            url = action.delete(:url)
            icon = action.delete(:icon) || "glyphicon glyphicon-trash"
            html_options = {
              :remote => true, 
              :class => "destroy",
              :method => :delete,
              :title => t("smart_listing.actions.destroy"),
              :data => {:confirmation => action.delete(:confirmation) || t("smart_listing.msgs.destroy_confirmation")},
            }.merge(action)

            concat(link_to(url, html_options) do
              concat(content_tag(:i, '', :class => icon))
            end)
          when :custom
            url = action.delete(:url)
            icon = action.delete(:icon)
            html_options = action

            concat(link_to(url, html_options) do
              concat(content_tag(:i, '', :class => icon))
            end)
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
      id = object.id if object
      object_key = options.delete(:object_key) || :object

      render(:partial => "smart_listing/item/#{item_action.to_s}", :locals => {:name => name, :id => id, :object_key => object_key, :object => object, :part => partial})
    end
  end
end
