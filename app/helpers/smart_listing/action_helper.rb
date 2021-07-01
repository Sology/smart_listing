module SmartListing
  module ActionHelper
    def smart_listing_action_tag(builder, action, target:, template: nil)
      target   = SmartListing::Builder.dom_id(builder, target)
      template = action.to_sym == :remove ? "" : "<template>#{template}</template>"

      %(<smart-listing-action name="#{action}" target="#{target}">#{template}</smart-listing-action>).html_safe
    end
  end
end
