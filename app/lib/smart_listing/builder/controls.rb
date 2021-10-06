module SmartListing
  class Builder
    class Controls
      attr_reader :builder

      delegate :base, :config, :view_context, to: :builder
      delegate :name, to: :base

      def initialize builder
        @builder = builder
      end

      def render_in view, &block
        classes = [config.classes(:controls)]
        datas = {
          config.data_attributes(:main) => name,
          controller: stimulus_controller,
          #turbo_permanent: true
          #action: "turbo:before-fetch-request->#{stimulus_controller}#beforeSend",
          turbo_frame: builder.dom_id('content')
        }

        view.form_tag(base.try(:href) || {}, :remote => base.config.global_options[:remote_mode] == :ujs, method: :get, class: classes, :data => datas) do
          # TODO: not sure if we need that?
          #view.concat(view.content_tag(:div, :style => "margin:0;padding:0;display:inline") do
            #view.concat(view.hidden_field_tag("#{base.try(:base_param)}[_]", 1, :id => nil)) # this forces smart_listing_update to refresh the list
          #end)
          view.concat(view.capture(self, &block))
        end
      end

      def observable_field_data initial_data = {}
        initial_data["#{stimulus_controller}_target"] = 'observable'
        initial_data.merge!(
          action: "change->#{stimulus_controller}#refresh keyup->#{stimulus_controller}#refresh"
        ) do |key, old, new|
          [old, new].join(' ')
        end
      end

      private

      def stimulus_controller
        config.global_options[:stimulus_controllers][:controls]
      end
    end
  end
end
