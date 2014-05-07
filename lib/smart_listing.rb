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

      sort_attributes = options.delete(:sort_attributes) || nil
      if sort_attributes == :default
        sort_attributes = collection.column_names.collect{|c| [c.to_sym, c]}
      end

      @options = {
        :param_names  => {                                      # param names
          :page                         => "#{@name}_page".to_sym,
          :per_page                     => "#{@name}_per_page".to_sym,
          :sort                         => "#{@name}_sort".to_sym,
        },
        :partial                        => @name,               # smart list partial name
        :array                          => false,               # controls whether smart list should be using arrays or AR collections
        :max_count                      => nil,                 # limit number of rows
        :unlimited_per_page             => false,               # allow infinite page size
        :sort_attributes                => sort_attributes,
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
      @page = params[param_names[:page]]
      @per_page = !params[param_names[:per_page]] || params[param_names[:per_page]].empty? ? (@options[:memorize_per_page] && cookies[param_names[:per_page]].to_i > 0 ? cookies[param_names[:per_page]].to_i : page_sizes.first) : params[param_names[:per_page]].to_i
      @per_page = DEFAULT_PAGE_SIZES.first unless DEFAULT_PAGE_SIZES.include?(@per_page)
      @sort = parse_sort(params[param_names[:sort]] || @options[:default_sort])
      puts @options[:sort_attributes].to_yaml
      puts @sort.to_yaml

      cookies[param_names[:per_page]] = @per_page if @options[:memorize_per_page]

      @count = @collection.size
      @count = @count.length if @count.is_a?(Hash)

      # Reset @page if greater than total number of pages
      no_pages = (@count.to_f / @per_page.to_f).ceil.to_i
      if @page.to_i > no_pages
        @page = no_pages
      end

      if @options[:array]
        if @sort && @sort.any? # when array we sort only by first attribute
          i = @options[:sort_attributes].index{|x| x[0] == @sort.first[0]}
          @collection = @collection.sort do |x, y|
            xval = x
            yval = y
            @options[:sort_attributes][i][1].split(".").each do |m|
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
        @collection = @collection.order(@options[:sort_attributes].collect{|s| "#{s[1]} #{@sort[s[0]]}" if @sort[s[0]]}.compact) if @sort && @sort.any?

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

    def all_params
      ap = {}
      @options[:param_names].each do |k, v|
        ap[v] = self.send(k)
      end
      ap
    end

    def sort_order attribute
      @sort[attribute] if @sort
    end

    private

    def parse_sort sort_params
      sort = nil
      @options[:sort_attributes].each do |a|
        k, v = a
        if sort_params[k.to_sym]
          dir = %w{asc desc}.delete(sort_params[k.to_sym])

          if dir
            sort ||= {}
            sort[k] = dir
          end
        end
      end if @options[:sort_attributes]

      sort
    end
  end
end
