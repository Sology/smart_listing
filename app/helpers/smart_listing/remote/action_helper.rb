module SmartListing
  module Remote
    module ActionHelper
      def smart_listing_action_tag(builder_or_base, action, target:, template: nil)
        target   = SmartListing::Builder.dom_id(builder_or_base, target)
        template = action.to_sym == :remove ? "" : "<template>#{template}</template>"
        
        case builder_or_base.config.global_options[:remote_mode]
        when :ujs
          %(<smart-listing-action name="#{action}" target="#{target}">#{template}</smart-listing-action>).html_safe
        when :turbo
          %(<smart-listing-action name="#{action}" target="#{target}">#{template}</smart-listing-action>).html_safe
        else
          raise "SmartListing `remote_mode` config option is not set"
        end
      end
    end
  end
end
