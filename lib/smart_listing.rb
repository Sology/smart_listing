require 'smart_listing/config'
require "smart_listing/engine"
require "kaminari"

module SmartListing
  class Base
    if Rails.env.development?
      DEFAULT_PAGE_SIZES = [3, 10, 20, 50, 100]
    else
      DEFAULT_PAGE_SIZES = [10, 20, 50, 100]
    end

    attr_reader :name, :collection, :options, :per_page, :sort, :page, :partial, :count

    def initialize name, collection, options = {}
      @name = name

      @options = {
        :param_names  => {                                      # param names
          :page                         => :page,
          :per_page                     => :per_page,
          :sort                         => :sort,
        },
        :partial                        => @name,               # smart list partial name
        :array                          => false,               # controls whether smart list should be using arrays or AR collections
        :max_count                      => nil,                 # limit number of rows
        :unlimited_per_page             => false,               # allow infinite page size
        :sort_attributes                => :implicit,           # allow implicitly setting sort attributes
        :default_sort                   => {},                  # default sorting
        :paginate                       => true,                # allow pagination
        :href                           => nil,                 # set smart list target url (in case when different than current url)
        :callback_href                  => nil,                 # set smart list callback url (in case when different than current url)
        :memorize_per_page              => false,
        :page_sizes                     => DEFAULT_PAGE_SIZES,  # set available page sizes array
        :kaminari_options               => {},                  # Kaminari's paginate helper options
      }.merge!(options)

      if @options[:array]
        @collection = collection.to_a
      else 
        @collection = collection
      end
    end

    def setup params, cookies
      @params = params

      @page = get_param :page
      @per_page = !get_param(:per_page) || get_param(:per_page).empty? ? (@options[:memorize_per_page] && get_param(:per_page, cookies).to_i > 0 ? get_param(:per_page, cookies).to_i : page_sizes.first) : get_param(:per_page).to_i
      @per_page = DEFAULT_PAGE_SIZES.first unless DEFAULT_PAGE_SIZES.include?(@per_page)

      @sort = parse_sort(get_param(:sort)) || @options[:default_sort]
      sort_keys = (@options[:sort_attributes] == :implicit ? @sort.keys.collect{|s| [s, s]} : @options[:sort_attributes])

      set_param(:per_page, @per_page, cookies) if @options[:memorize_per_page]

      @count = @collection.size
      @count = @count.length if @count.is_a?(Hash)

      # Reset @page if greater than total number of pages
      no_pages = (@count.to_f / @per_page.to_f).ceil.to_i
      if @page.to_i > no_pages
        @page = no_pages
      end

      if @options[:array]
        if @sort && @sort.any? # when array we sort only by first attribute
          i = sort_keys.index{|x| x[0] == @sort.first[0]}
          @collection = @collection.sort do |x, y|
            xval = x
            yval = y
            sort_keys[i][1].split(".").each do |m|
              xval = xval.try(m)
              yval = yval.try(m)
            end
            xval = xval.upcase if xval.is_a?(String)
            yval = yval.upcase if yval.is_a?(String)

            if xval.nil? || yval.nil?
              xval.nil? ? 1 : -1
            else
              if @sort.first[1] == "asc"
                (xval <=> yval) || (xval && !yval ? 1 : -1)
              else
                (yval <=> xval) || (yval && !xval ? 1 : -1)
              end
            end 
          end 
        end
        if @options[:paginate] && @per_page > 0
          @collection = ::Kaminari.paginate_array(@collection).page(@page).per(@per_page)
          if @collection.length == 0
            @collection = @collection.page(@collection.num_pages)
          end
        end
      else
        # let's sort by all attributes
        @collection = @collection.order(sort_keys.collect{|s| "#{s[1]} #{@sort[s[0]]}" if @sort[s[0]]}.compact) if @sort && @sort.any?

        if @options[:paginate] && @per_page > 0
          @collection = @collection.page(@page).per(@per_page)
        end
      end
    end

    def partial
      @options[:partial]
    end

    def param_names
      @options[:param_names]
    end

    def param_name key
      "#{base_param}[#{param_names[key]}]"
    end

    def unlimited_per_page?
      !!@options[:unlimited_per_page]
    end

    def max_count
      @options[:max_count]
    end

    def href
      @options[:href]
    end

    def callback_href
      @options[:callback_href]
    end

    def page_sizes
      @options[:page_sizes]
    end

    def kaminari_options
      @options[:kaminari_options]
    end

    def all_params overrides = {}
      ap = {base_param => {}}
      @options[:param_names].each do |k, v|
        if overrides[k]
          ap[base_param][v] = overrides[k]
        else
          ap[base_param][v] = self.send(k)
        end
      end
      ap
    end

    def sort_order attribute
      @sort && @sort[attribute].present? ? @sort[attribute] : nil
    end

    def base_param
      "#{name}_smart_listing"
    end

    private

    def get_param key, store = @params
      if store.is_a?(ActionDispatch::Cookies::CookieJar)
        store["#{base_param}_#{param_names[key]}"]
      else
        store[base_param].try(:[], param_names[key])
      end
    end

    def set_param key, value, store = @params
      if store.is_a?(ActionDispatch::Cookies::CookieJar)
        store["#{base_param}_#{param_names[key]}"] = value
      else
        store[base_param] ||= {}
        store[base_param][param_names[key]] = value
      end
    end

    def parse_sort sort_params
      sort = nil

      if @options[:sort_attributes] == :implicit
        sort = sort_params.dup if sort_params
      elsif @options[:sort_attributes]
        @options[:sort_attributes].each do |a|
          k, v = a
          if sort_params && sort_params[k.to_s]
            dir = ["asc", "desc", ""].delete(sort_params[k.to_s])

            if dir
              sort ||= {}
              sort[k] = dir
            end
          end
        end
      end

      sort
    end
  end
end
