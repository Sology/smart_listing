module SmartListing
  class Builder
    # To be used in views responding to `smart_listing_remote` request type 
    # i.e. `index.smart_listing.erb`.
    class Remote
      include SmartListing::Remote::ActionHelper 
      attr_reader :builder

      delegate :base, :view_context, to: :builder

      def initialize builder
        @builder = builder
      end

      def index(content = nil, **rendering, &block)
        if content == nil && !rendering.has_key?(:partial)
          rendering[:partial] = base.partial
        end

        action :replace, :list, content, **rendering, &block
      end

      def show(item, content = nil, **rendering, &block)
        action :replace, item, content, **rendering, &block
      end

      def edit(item, content = nil, **rendering, &block)
        action :replace, item, content, **rendering, &block
      end

      def update(item, content = nil, **rendering, &block)
        action :replace, item, content, **rendering, &block
      end

      def destroy(item)
        smart_listing_action_tag builder, :remove, target: item
      end

      def action(name, target, content = nil, **rendering, &block)
        case
        when content
          smart_listing_action_tag builder, name, target: target, template: content
        when block_given?
          smart_listing_action_tag builder, name, target: target, template: view_context.capture(&block)
        when rendering.any?
          rendering[:locals] ||= {}
          rendering[:locals].reverse_merge!(smart_listing: builder)

          smart_listing_action_tag builder, name, target: target, template: view_context.render(formats: [ :html ], **rendering)
        else
          smart_listing_action_tag builder, name, target: target, template: view_context.render(partial: target, formats: :html)
        end
      end
    end
  end
end
