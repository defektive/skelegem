require "thor"
require "rubygems"

module Skelegem
  module Templates

    class ThorCLI < Thor::Group

      include Thor::Actions

      argument :name

      def self.source_root
        File.dirname __FILE__
      end

      def setup_files
        template "cli.tt", "lib/#{name}/cli.rb"

        File.delete "bin/#{name}"
        template "bin.tt", "bin/#{name}"
        chmod "bin/#{name}", 0755
      end
    end
  end
end
