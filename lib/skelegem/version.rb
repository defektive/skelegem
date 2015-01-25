require 'semver'

module Skelegem
  VERSION = SemVer.find(File.dirname(__FILE__)+ "/../../").format "%M.%m.%p%s"
end
