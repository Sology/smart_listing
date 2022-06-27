module SmartListing
  class Builder
    class << self
      def dom_id name_or_instance, item = nil
        instance_key = name_or_instance.respond_to?(:to_key) ? name_or_instance.to_key : name_or_instance.to_s.dasherize
        item_key = item && (item.respond_to?(:to_key) ? ActionView::RecordIdentifier.dom_id(item) : item.to_s.dasherize)

        ['smart-listing', instance_key, item_key].compact.join('-')
      end
    end
    attr_reader :base, :options, :view_context

    delegate :name, :config, :to_key, to: :base
    delegate :content_tag, :concat, :capture, to: :view_context

    def initialize(base, view_context, options)
      @base = base

      @view_context = view_context
      @view_context.formats ||= [:html]

      @options = options
    end

    def remote
      @remote ||= Remote.new(self)
    end

    def actions specs = []
      Actions.new(self, specs)
    end

    def controls
      @controls ||= Controls.new(self)
    end

    def container &block
      if options[:bare]
        capture(builder, &block)
      else
        case base.config.global_options[:remote_mode]
        when :turbo
          content_element = :"turbo-frame"
          event_names = {
            before: 'turbo:before-fetch-request',
            complete: 'turbo:frame-load'
          }
        when :ujs
          content_element = :div
          event_names = {
            before: 'ajax:beforeSend',
            complete: 'ajax:complete',
          }
        end

        data = {
          config.data_attributes(:max_count) => (base.max_count if base.max_count&.positive?),
          config.data_attributes(:item_count) => base.count,
          config.data_attributes(:href) => base.href,
          config.data_attributes(:callback_href) => base.callback_href,
          "#{stimulus_controller}_name_value" => name,
          controller: stimulus_controller,
          action: "#{event_names[:before]}->#{stimulus_controller}#beforeSend #{event_names[:complete]}->#{stimulus_controller}#update",
        }.merge(options[:data] || {})

        content_tag(:div, class: config.classes(:main), id: dom_id, data: data) do
          concat(content_tag(content_element, id: dom_id(:content)) do
            concat(capture(self, &block))
          end)
        end
      end
    end

    def wrapper target, options = {}, &block
      name = options.delete(:name) || 'smart-listing-wrapper'

      content_tag(name, {id: dom_id(target)}, &block)
    end

    def dom_id(target = nil)
      self.class.dom_id(self, target)
    end

    def render_in *args
      container do |smart_listing|
        concat(smart_listing.render_list)
      end
    end

    # Renders the main partial (whole list)
    def render_list locals = {}
      if base.partial
        wrapper :list do
          concat(view_context.render(:partial => base.partial, :locals => {:smart_listing => self}.merge(locals || {})))
        end
      end
    end

    # FIXME
    def render_each(*args, &block)
      if args.last.is_a?(Hash) && args.last.extractable_options?
        wrapper_options = args.last.delete(:wrapper)
      end

      base.collection.collect do |item|
        wrapper(item, wrapper_options) do
          if block_given?
            concat(capture(item, &block))
          else
            concat(render(*args))
          end
        end
      end.join.html_safe
    end

    # Basic render block wrapper that adds smart_listing reference to local variables
    def render options = {}, locals = {}, &block
      locals.merge!(smart_listing: self)
      options[:locals].merge!(smart_listing: self, foo: 1) if options.is_a?(Hash)

      view_context.render options, locals, &block
    end


    def paginate options = {}
      if base.collection.respond_to? :current_page
        view_context.paginate base.collection, **{:remote => base.remote?, :param_name => base.param_name(:page)}.merge(base.kaminari_options)
      end
    end

    def collection
      base.collection
    end

    # Check if smart list is empty
    def empty?
      base.count == 0
    end

    def pagination_per_page_links options = {}
      # TODO: move the class specification to template (possibly without using config)
      container_classes = [config.classes(:pagination_per_page)]
      container_classes << config.classes(:hidden) if empty?

      per_page_sizes = base.page_sizes.clone
      per_page_sizes.push(0) if base.unlimited_per_page?

      locals = {
        :container_classes => container_classes,
        :per_page_sizes => per_page_sizes,
      }

      view_context.render(:partial => 'smart_listing/pagination_per_page_links', :locals => default_locals.merge(locals))
    end

    def pagination_per_page_link page
      if base.per_page.to_i != page
        url = view_context.url_for(base.params.merge(base.all_params(:per_page => page, :page => 1)))
      end

      locals = {
        :page => page,
        :url => url,
      }

      view_context.render(:partial => 'smart_listing/pagination_per_page_link', :locals => default_locals.merge(locals))
    end

    def sortable title, attribute, options = {}
      dirs = options[:sort_dirs] || base.sort_dirs || [nil, "asc", "desc"]

      next_index = dirs.index(base.sort_order(attribute)).nil? ? 0 : (dirs.index(base.sort_order(attribute)) + 1) % dirs.length

      sort_params = {
        attribute => dirs[next_index]
      }

      locals = {
        :order => base.sort_order(attribute),
        :url => view_context.url_for(base.params.merge(base.all_params(:sort => sort_params))),
        :container_classes => [config.classes(:sortable)],
        :attribute => attribute,
        :title => title,
        :remote => base.remote?
      }

      view_context.render(:partial => 'smart_listing/sortable', :locals => default_locals.merge(locals))
    end

    def update options = {}
      part = options.delete(:partial) || base.partial || base_name

      view_context.render(:partial => 'smart_listing/update_list', :locals => {:name => base_name, :part => part, :smart_listing => self})
    end

    # Add new item button & placeholder to list
    def item_new options = {}, &block
      no_records_classes = [view_context.smart_listing_config.classes(:no_records)]
      no_records_classes << view_context.smart_listing_config.classes(:hidden) unless empty?
      new_item_button_classes = []
      new_item_button_classes << view_context.smart_listing_config.classes(:hidden) if max_count?

      locals = {
        :colspan => options.delete(:colspan),
        :no_items_classes => no_records_classes,
        :no_items_text => options.delete(:no_items_text) || view_context.t("smart_listing.msgs.no_items"),
        :new_item_button_url => options.delete(:link),
        :new_item_button_classes => new_item_button_classes,
        :new_item_button_text => options.delete(:text) || view_context.t("smart_listing.actions.new"),
        :new_item_autoshow => block_given?,
        :new_item_content => nil,
      }

      unless block_given?
        locals[:placeholder_classes] = [view_context.smart_listing_config.classes(:new_item_placeholder), view_context.smart_listing_config.classes(:hidden)]
        locals[:new_item_action_classes] = [view_context.smart_listing_config.classes(:new_item_action)]
        locals[:new_item_action_classes] << view_context.smart_listing_config.classes(:hidden) if !empty? && max_count?

        view_context.render(:partial => 'smart_listing/item_new', :locals => default_locals.merge(locals))
      else
        locals[:placeholder_classes] = [view_context.smart_listing_config.classes(:new_item_placeholder)]
        locals[:placeholder_classes] << view_context.smart_listing_config.classes(:hidden) if !empty? && max_count?
        locals[:new_item_action_classes] = [view_context.smart_listing_config.classes(:new_item_action), view_context.smart_listing_config.classes(:hidden)]

        locals[:new_item_content] = view_context.capture(&block)
        view_context.render(:partial => 'smart_listing/item_new', :locals => default_locals.merge(locals))
      end
    end

    def count
      base.count
    end

    # Check if smart list reached its item max count
    def max_count?
      return false if base.max_count.nil?
      base.count >= base.max_count
    end

    private

    def default_locals
      {:smart_listing => base, :builder => self}
    end

    def stimulus_controller
      config.global_options[:stimulus_controllers][:main]
    end
  end
end
