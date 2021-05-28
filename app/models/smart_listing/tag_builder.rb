class SmartListing::TagBuilder
  def initialize(view_context)
    @view_context = view_context
    @view_context.formats |= [:html]
  end

  def index(target, content = nil, **rendering, &block)
    action :update, target, content, **rendering, &block
  end

  def action(name, target, content = nil, allow_inferred_rendering: true, **rendering, &block)
    target_name = extract_target_name_from(target)

    case
    when content
      smart_listing_action_tag name, target: target_name, template: (render_record(content) if allow_inferred_rendering) || content
    when block_given?
      smart_listing_action_tag name, target: target_name, template: @view_context.capture(&block)
    when rendering.any?
      smart_listing_action_tag name, target: target_name, template: @view_context.render(formats: [ :html ], **rendering)
    else
      smart_listing_action_tag name, target: target_name, template: (render_record(target) if allow_inferred_rendering)
    end
  end

  def smart_listing_action_tag(action, target:, template: nil)
    target   = convert_to_smart_listing_dom_id(target)
    template = action.to_sym == :remove ? "" : "<template>#{template}</template>"

    %(<smart-listing action="#{action}" target="#{target}">#{template}</smart-listing>).html_safe
  end

  private
  
  def extract_target_name_from(target)
    if target.respond_to?(:to_key)
      ActionView::RecordIdentifier.dom_id(target)
    else
      target
    end
  end

  def render_record(possible_record)
    if possible_record.respond_to?(:to_partial_path)
      record = possible_record
      @view_context.render(partial: record, formats: :html)
    end
  end

  def convert_to_smart_listing_dom_id(target)
    target.respond_to?(:to_key) ? ActionView::RecordIdentifier.dom_id(target) : target
  end
end
