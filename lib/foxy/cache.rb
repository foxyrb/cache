# frozen_string_literal: true

require "foxy/cache/version"

module Foxy
  module Cache
    class Error < StandardError; end

    def self.new(*args, **kws)
      Foxy::Cache::Manager.new(*args, **kws)
    end
  end
end

Dir["#{__dir__}/cache/**/*.rb"]
  .sort
  .each { |file| require file }
