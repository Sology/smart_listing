module SmartListing
  class Builder
    class Actions
      attr_reader :builder, :specs

      delegate :base, :config, :view_context, to: :builder
      delegate :content_tag, :concat, :capture, :render, to: :view_context

      def initialize builder, specs = []
        @builder = builder
        @specs = specs
      end

      def render_in *args
        content_tag(:span) do
          specs.each do |action|
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
              locals[:icon] ||= config.classes(:icon_show)
              template = 'action_show'
            when :edit
              locals[:icon] ||= config.classes(:icon_edit)
              template = 'action_edit'
            when :destroy
              locals[:icon] ||= config.classes(:icon_trash)
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

            locals[:icon] = [locals[:icon], config.classes(:muted)] if !locals[:action_if]

            if template
              concat(render(:partial => "smart_listing/#{template}", :locals => locals))
            else
              concat(render(:partial => "smart_listing/action_#{action_name}", :locals => {:action => action}))
            end
          end
        end
      end
    end
  end
end
