module SmartListing
  module Generators
    class ManagementGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates/management', __FILE__)

      def create_views
        available_views.each do |file_name|
          template file_name, File.join("app/views", plural_name, file_name)
        end
      end

      private

      def columns
        args
      end

      def edit_path
        "edit_#{singular_name}_path(object)"
      end

      def new_path
        "new_#{singular_name}_path"
      end

      def resource_path
        "#{singular_name}_path(object)"
      end

      def resource_sym
        ":#{plural_name}"
      end

      def available_views
        source_paths.map do |source_path|
          if File.directory?(source_path)
            Dir.entries(source_path).select {|f| !File.directory? f}
          end
        end.flatten.compact
      end
    end
  end
end
