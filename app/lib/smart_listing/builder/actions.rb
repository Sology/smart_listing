module SmartListing
  class Builder
    class Actions
      include SmartListing::ActionHelper

      attr_reader :builder

      delegate :base, :view_context, to: :builder

      def initialize builder
        @builder = builder
      end

      def index(content = nil, **rendering, &block)
        if content == nil && !rendering.has_key?(:partial)
          rendering[:partial] = base.partial
          rendering[:locals] ||= {}
          rendering[:locals].reverse_merge!(smart_listing: builder)
        end

        action :index, :list, content, **rendering, &block
      end

      def action(name, target, content = nil, **rendering, &block)
        case
        when content
          smart_listing_action_tag builder, name, target: target, template: content
        when block_given?
          smart_listing_action_tag builder, name, target: target, template: view_context.capture(&block)
        when rendering.any?
          smart_listing_action_tag builder, name, target: target, template: view_context.render(formats: [ :html ], **rendering)
        else
          smart_listing_action_tag builder, name, target: target, template: view_context.render(partial: target, formats: :html)
        end
      end
    end
  end
end
