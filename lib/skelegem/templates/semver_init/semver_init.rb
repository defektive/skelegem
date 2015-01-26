require "thor"
require "rubygems"

module Skelegem
  module Templates

    class SemverInit < Thor::Group

      include Thor::Actions

      argument :name

      def self.source_root
        File.dirname(__FILE__)
      end

      def init_semver
        version = SemVer.new
        version.save ".semver"

        # Object.send(:remove_const, :SemVer)
      end

      def create_lib_file
        File.delete "lib/#{name}/version.rb"
        template('version.tt', "lib/#{name}/version.rb")
      end

      def update_gemspec
        my_spec = Skelegem::Store.gemspec
        tmp_spec = Gem::Specification::from_yaml( `gem spec semver2 -r` )


        # puts "Adding #{tmp_spec.name}, #{tmp_spec.requirement.to_s}"
        my_spec.add_dependency tmp_spec.name, tmp_spec.version.to_s
      end
    end
  end
end
