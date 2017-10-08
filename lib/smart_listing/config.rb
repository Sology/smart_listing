module SmartListing
  mattr_reader :configs

  def self.configure profile = nil
    profile ||= :default
    @@configs ||= {}
    yield @@configs[profile] ||= SmartListing::Configuration.new
  end

  def self.config profile = nil
    profile ||= :default
    @@configs ||= {}
    @@configs[profile] ||= SmartListing::Configuration.new
  end

  class Configuration
    DEFAULT_PAGE_SIZES = [10, 20, 50, 100].freeze

    DEFAULTS = {
      :global_options => {
        :param_names  => {                                      # param names
          :page                         => :page,
          :per_page                     => :per_page,
          :sort                         => :sort,
        },
        :array                          => false,                       # controls whether smart list should be using arrays or AR collections
        :max_count                      => nil,                         # limit number of rows
        :unlimited_per_page             => false,                       # allow infinite page size
        :paginate                       => true,                        # allow pagination
        :memorize_per_page              => false,
        :page_sizes                     => DEFAULT_PAGE_SIZES.dup,      # set available page sizes array
        :kaminari_options               => {:theme => "smart_listing"}, # Kaminari's paginate helper options
        :sort_dirs                      => [nil, "asc", "desc"],        # Default sorting directions cycle of sortables
        :remote                         => true,                        # Default remote mode
      },
      :constants => {
        :classes => {
          :main => "smart-listing",
          :editable => "editable",
          :content => "content",
          :loading => "loading",
          :status => "smart-listing-status",
          :item_actions => "actions",
          :new_item_placeholder => "new-item-placeholder",
          :new_item_action => "new-item-action",
          :new_item_button => "btn",
          :hidden => "hidden",
          :autoselect => "autoselect",
          :callback => "callback",
          :pagination_wrapper => "text-center",
          :pagination_container => "pagination",
          :pagination_per_page => "pagination-per-page text-center",
          :inline_editing => "info",
          :no_records => "no-records",
          :limit => "smart-listing-limit",
          :limit_alert => "smart-listing-limit-alert",
          :controls => "smart-listing-controls",
          :controls_reset => "reset",
          :filtering => "filter",
          :filtering_search => "glyphicon-search",
          :filtering_cancel => "glyphicon-remove",
          :filtering_disabled => "disabled",
          :sortable => "sortable",
          :icon_new => "glyphicon glyphicon-plus",
          :icon_edit => "glyphicon glyphicon-pencil",
          :icon_trash => "glyphicon glyphicon-trash",
          :icon_inactive => "glyphicon glyphicon-remove-circle text-muted",
          :icon_show => "glyphicon glyphicon-share-alt",
          :icon_sort_none => "glyphicon glyphicon-resize-vertical",
          :icon_sort_up => "glyphicon glyphicon-chevron-up",
          :icon_sort_down => "glyphicon glyphicon-chevron-down",
          :muted => "text-muted",
        },
        :data_attributes => {
          :main => "smart-listing",
          :controls_initialized => "smart-listing-controls-initialized",
          :confirmation => "confirmation",
          :id => "id",
          :href => "href",
          :callback_href => "callback-href",
          :max_count => "max-count",
          :item_count => "item-count",
          :inline_edit_backup => "smart-listing-edit-backup",
          :params => "params",
          :observed => "observed",
          :autoshow => "autoshow",
          :popover => "slpopover",
        },
        :selectors => {
          :item_action_destroy => "a.destroy",
          :edit_cancel => "button.cancel",
          :row => "tr",
          :head => "thead",
          :filtering_button => "button",
          :filtering_icon => "button span",
          :filtering_input => ".filter input",
          :pagination_count => ".pagination-per-page .count",
        },
        :element_templates => {
          :row => "<tr />",
        },
        :bootstrap_commands => {
          :popover_destroy => "destroy",
        }
      }
    }.freeze

    attr_reader :options

    def initialize
      @options = {}
    end

    def method_missing(sym, *args, &block)
      @options[sym] = *args
    end
    
    def constants key, value = nil
      if value && !value.empty?
        @options[:constants] ||= {}
        @options[:constants][key] ||= {}
        @options[:constants][key].merge!(value)
      end
      @options[:constants].try(:[], key) || DEFAULTS[:constants][key]
    end

    def classes key
      @options[:constants].try(:[], :classes).try(:[], key) || DEFAULTS[:constants][:classes][key]
    end

    def data_attributes key
      @options[:constants].try(:[], :data_attributes).try(:[], key) || DEFAULTS[:constants][:data_attributes][key]
    end

    def selectors key
      @options[:constants].try(:[], :selectors).try(:[], key) || DEFAULTS[:constants][:selectors][key]
    end

    def element_templates key
      @options[:constants].try(:[], :element_templates).try(:[], key) || DEFAULTS[:constants][:element_templates][key]
    end

    def global_options value = nil
      if value && !value.empty?
        @options[:global_options] ||= {}
        @options[:global_options].merge!(value)
      end
      !@options[:global_options] ? DEFAULTS[:global_options] : DEFAULTS[:global_options].deep_merge(@options[:global_options])
    end
    
    def to_json
      @options.to_json
    end

    def dump
      DEFAULTS.deep_merge(@options)
    end

    def dump_json
      dump.to_json
    end
  end
end
