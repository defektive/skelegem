# Useful title goes here

## Creating a basic gem

### Prereqs

Bundler - who doesn't use this
Semver2 semantic versioning made bearable

```
gem install semver2 bundler
```

If you use rbenv now would be a good to to run `rbenv rehash`

### Generate gem skeleton
Bundler can create a gem skeleton for you

```bash
defektive/gems [ bundle help gem                                                                                                   ] 12:03 PM
Usage:
  bundle gem GEM [OPTIONS]

Options:
  -b, [--bin=Generate a binary for your library.]
  -t, [--test=Generate a test directory for your library: 'rspec' is the default, but 'minitest' is also supported.]
  -e, [--edit=/path/to/your/editor]                                                                                   # Open generated gemspec in the specified editor (defaults to $EDITOR or $BUNDLER_EDITOR)
      [--ext=Generate the boilerplate for C extension code]
      [--no-color=Disable colorization in output]
  -V, [--verbose=Enable verbose output mode]
  -r, [--retry=Specify the number of times you wish to attempt network commands]

Creates a skeleton for creating a rubygem
```

Lets try it out
```
bundle gem skelegem -bte

# Your editor should have opened up with your new gemspec
# update the description and summary
# add the following dependencies
# 
# spec.add_runtime_dependency "semver2", '~>3.4'
# spec.add_runtime_dependency "thor", '0.19.1'

cd skelegem
bundle
semver init
```

### Update our **version.rb** 
In order to leverage the awesomeness of semver, you'll have to update
the version.rb to look something like this

```ruby
require 'semver'

module Skelegem
  VERSION = SemVer.find(File.dirname(__FILE__)+ "/../../").format "%M.%m.%p%s"
end
```

### Add our first command

Add `require "skelegem/cli"` to the top of *lib/skelegem.rb*. Create 
*lib/skelegem/cli.rb* with the following contents

```ruby
require "skelegem/version"
require "thor" 

module Skelegem
  # Lets extend Thor
  class CLI < Thor
    # map -v to the version  so we can do skelegem -v to get version info
    map "-v" => :version

    # a very basic action
    desc "version", "print out the app version"
    def version()
      puts "#{self.class.name.split("::")[0]} #{Skelegem::VERSION}"
    end
  end
end
```

### Summary

We should now have a basic gem. Test it out by running `bundle exec bin/skelegem`.
Notice how the `desc` line of code is what shows up here to describe what the 
action does. Try out `bundle exec bin/skelegem -v`. Run `semver inc patch` and 
then run `bundle exec bin/skelegem -v`, you should get something like

```bash
gems/skelegem [ bundle exec skelegem -v
Skelegem 0.0.1
```

You can now run `rake install` to intall the gem. Again if you use rbenv, you should do a `rbenv rehash` now.

Now you should be able to use the gem without bundle exec. Try it. `skelegem -v`

I think we are ready to commit all of our progress.

```bash
git add .
git ci -am "Initial commit"
```

## Adding usefullness

Now its time to make our lives easier. All that stuff above was pretty tedious. Lets make it easy to do things like that.

(after going through the the steps. this was much bigger than i anticipated)


### Thor templates

Lets create a directory called templates in `lib/skelegem`. We will also want to create a `templates.rb` in lib. Our 
directory tree will end up looking something like

```bash
lib/skelegem/templates
├── gemspec
│   ├── gemspec.rb
│   └── gemspec.tt
├── semver_init
│   ├── semver_init.rb
│   └── version.tt
└── thor_cli
    ├── bin.tt
    ├── cli.tt
    └── thor_cli.rb
```

Here we will create Thor::Groups and templates.

#### The gemspec

`lib/skelegem/templates/gemspec/gemspec.tt`

    # coding: utf-8
    lib = File.expand_path('../lib', __FILE__)
    $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
    require '<%= config[:my_spec].name %>/version'

    Gem::Specification.new do |spec|
      spec.name          = "<%= config[:my_spec].name %>"
      spec.version       = <%= (config[:my_spec].name.split("_").map{|f| f.capitalize}.join) %>::VERSION
      spec.authors       = <%= config[:my_spec].authors.to_s %>
      spec.email         = <%= config[:my_spec].email.to_s %>
      spec.summary       = %q{<%= config[:my_spec].summary %>}
      spec.description   = %q{<%= config[:my_spec].description %>}
      spec.homepage      = "<%= config[:my_spec].homepage %>"
      spec.license       = "<%= config[:my_spec].license %>"

      spec.files         = `git ls-files -z`.split("\x0")
      spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
      spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
      spec.require_paths = <%= config[:my_spec].require_paths.to_s %>

      <% config[:my_spec].runtime_dependencies.each do |dep| %>
      spec.add_runtime_dependency "<%= dep.name %>", '<%= dep.requirement.to_s %>'<% end %>

      <% config[:my_spec].development_dependencies.each do |dep| %>
      spec.add_development_dependency "<%= dep.name %>", '<%= dep.requirement.to_s %>'<% end %>
    end

`lib/skelegem/templates/gemspec/gemspec.rb`

```ruby
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
```

We've modified the default bundler gemspec template to be more configurable. Setup a `Thor::Group` to save out 
a gemspec object. The real magic happens back in `cli.rb`. We need to add a new edit method, and some other util
methods

```ruby

    # [code not shown] ....

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

          # this will come in handy later
          invoke Skelegem::Templates::ThorCLI if dep == "thor"

          tmp_spec = Gem::Specification::from_yaml( exec "gem spec #{dep} -r" )
          my_spec.add_dependency tmp_spec.name, tmp_spec.version.to_s
        end
      end
    end

    no_commands {
      # [code not shown] ....

      def my_spec_file
        @my_spec_file ||= Dir.glob("*.gemspec").first
      end

      def my_spec
        @my_spec ||= Gem::Specification::load my_spec_file
      end
    }
```

We've used some new methods here. `ask` does just what it sounds like. It will prompt the user for some input. 

#### I am tired. and I procrastinated.

After reading docs and source code for the gem specification, thor, and ruby(I didn't read the ruby source code)(I am new to this ruby thing). Let me summarize.

If your using semver and you haven't ran `semver init`. Attempting to run `bundle install` will peg your cpu
until you kill it.

Gem::Specification.to_ruby isn't as cool as it sounds. Yes you get ruby code. You will also lose an custom code
you have added to the gemspec. :(

Thor templates are pretty useful. Skelegem is basically a thor file and some custom templates.

Thor's documentation sucks. I found myself reading the code to see whats happening.

Pry seems very awesome. I wanted to use it to add a interactive sheel to skelegem

There has to be a better way to share thor instance vars with the templates.

Not sure if you noticed, but documentation is cool.

I chose to automate gem creation for this. I have used this to 

- Automate console connections to prod
- Automatically fetch all the logs from an appserver for a given context
- Grepping kibana






