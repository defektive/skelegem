

module Skelegem
  class Store
    def self.gemspec(spec = nil)
      @spec = @spec || spec
    end
  end
end
