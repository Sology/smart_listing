SmartListing.configure do |config|
  config.global_options({
    #:param_names  => {                                              # param names
      #:page                         => :page,
      #:per_page                     => :per_page,
      #:sort                         => :sort,
    #},
    #:array                          => false,                       # controls whether smart list should be using arrays or AR collections
    #:max_count                      => nil,                         # limit number of rows
    #:unlimited_per_page             => false,                       # allow infinite page size
    #:paginate                       => true,                        # allow pagination
    #:memorize_per_page              => false,                       # save per page settings in the cookie
    #:page_sizes                     => DEFAULT_PAGE_SIZES,          # set available page sizes array
    #:kaminari_options               => {:theme => "smart_listing"}, # Kaminari's paginate helper options
    #:sort_dirs                      => [nil, "asc", "desc"],        # Default sorting directions cycle of sortables
  })

  config.constants :classes, {
    #:main                  => "smart-listing",
    #:editable              => "editable",
    #:content               => "content",
    #:loading               => "loading",
    #:status                => "smart-listing-status",
    #:item_actions          => "actions",
    #:new_item_placeholder  => "new-item-placeholder",
    #:new_item_action       => "new-item-action",
    #:new_item_button       => "btn",
    #:hidden                => "hidden",
    #:autoselect            => "autoselect",
    #:callback              => "callback",
    #:pagination_wrapper    => "text-center",
    #:pagination_container  => "pagination",
    #:pagination_per_page   => "pagination-per-page text-center",
    #:inline_editing        => "info",
    #:no_records            => "no-records",
    #:limit                 => "smart-listing-limit",
    #:limit_alert           => "smart-listing-limit-alert",
    #:controls              => "smart-listing-controls",
    #:controls_reset        => "reset",
    #:filtering             => "filter",
    #:filtering_search      => "glyphicon-search",
    #:filtering_cancel      => "glyphicon-remove",
    #:filtering_disabled    => "disabled",
    #:sortable              => "sortable",
    #:icon_new              => "glyphicon glyphicon-plus",
    #:icon_edit             => "glyphicon glyphicon-pencil",
    #:icon_trash            => "glyphicon glyphicon-trash",
    #:icon_inactive         => "glyphicon glyphicon-circle",
    #:icon_show             => "glyphicon glyphicon-share-alt",
    #:icon_sort_none        => "glyphicon glyphicon-resize-vertical",
    #:icon_sort_up          => "glyphicon glyphicon-chevron-up",
    #:icon_sort_down        => "glyphicon glyphicon-chevron-down",
    #:muted                 => "text-muted",
  }

  config.constants :data_attributes, {
    #:main                  => "smart-listing",
    #:controls_initialized  => "smart-listing-controls-initialized",
    #:confirmation          => "confirmation",
    #:id                    => "id",
    #:href                  => "href",
    #:callback_href         => "callback-href",
    #:max_count             => "max-count",
    #:item_count            => "item-count",
    #:inline_edit_backup    => "smart-listing-edit-backup",
    #:params                => "params",
    #:observed              => "observed",
    #:href                  => "href",
    #:autoshow              => "autoshow",
    #:popover               => "slpopover",
  }

  config.constants :selectors, {
    #:item_action_destroy   => "a.destroy",
    #:edit_cancel           => "button.cancel",
    #:row                   => "tr",
    #:head                  => "thead",
    #:filtering_icon        => "i"
    #:filtering_button      => "button",
    #:filtering_icon        => "button span",
    #:filtering_input       => ".filter input",
    #:pagination_count      => ".pagination-per-page .count",
  }

  config.constants :element_templates, {
    #:row => "<tr />",
  }
end
