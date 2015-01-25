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
Notice how the `desc` line of code is what shows up here to describe what the action does. Try out `bundle exec bin/skelegem -v`