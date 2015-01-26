require "skelegem/version"
require "thor"
require "rubygems"

module Skelegem
  class CLI < Thor
    map "-v" => :version

    desc "version", "print out the app version"
    def version()
      puts "#{self.class.name.split("::")[0]} #{Skelegem::VERSION}"
    end

    desc "new", "create a new gem"
    method_option :edit, :type => :string, :aliases => "-e", :default => false
    def new(name=nil)
      if name == nil
        name = ask("What would you like your gem called? ")
      end

      puts "Generating #{name}"
      execute "bundle gem #{name} -bt"

      Dir.chdir name 
      Skelegem::Store.gemspec my_spec

      invoke Skelegem::Templates::SemverInit
      edit if options[:edit]
      invoke Skelegem::Templates::Gemspec
      Kernel.exec "bundle install"
    end

    desc "edit", "edit gemspec"
    # method_option :name, :type => :boolean, :aliases => "-n"
    def edit()

      summary = ask("Summary: <#{my_spec.summary}>")
      my_spec.summary = summary unless summary.empty? 

      description = ask("Description: <#{my_spec.description}>")
      my_spec.description = description unless description.empty?

      puts "Current dependencies"
      my_spec.runtime_dependencies.each do |rdep|
        puts rdep.name
      end

      dependencies = ask("Any additional dependencies you'd like added? [empty for none]")
      unless dependencies.empty?
        dependencies = dependencies.split(" ").each do |dep|
          puts "adding #{dep}"
          invoke Skelegem::Templates::ThorCLI if dep == "thor"

          tmp_spec = Gem::Specification::from_yaml( exec "gem spec #{dep} -r" )
          my_spec.add_dependency tmp_spec.name, tmp_spec.version.to_s
        end
      end
    end

    no_commands {
      def execute(cmd)
        system(cmd)
      end

      def exec(cmd)
        `#{cmd}`
      end

      def my_spec_file
        @my_spec_file ||= Dir.glob("*.gemspec").first
      end

      def my_spec
        @my_spec ||= Gem::Specification::load my_spec_file
      end
    }
  end
end
