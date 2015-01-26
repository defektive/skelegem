require "thor"
require "rubygems"

module Skelegem
  module Templates

    class Gemspec < Thor::Group

      include Thor::Actions
      argument :name

      def self.source_root
        File.dirname(__FILE__)
      end

      def create_lib_file
        my_spec = Skelegem::Store.gemspec
        File.delete "#{name}.gemspec"
        template('gemspec.tt', "#{name}.gemspec", :my_spec => my_spec)
      end
    end
  end
end
