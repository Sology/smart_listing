module SmartListing::SmartListingTagBuilder
  private

  def turbo_stream
    SmartListing::TagBuilder.new(view_context)
  end
end
