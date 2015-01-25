require "skelegem/version"
require "thor"

module Skelegem
  class CLI < Thor
    map "-v" => :version

    desc "version", "print out the app version"
    def version()
      puts "#{self.class.name.split("::")[0]} #{Skelegem::VERSION}"
    end

    no_commands {
    }
  end
end
