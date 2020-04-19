# frozen_string_literal: true

require "foxy/cache/version"

module Foxy
  module Cache
    class Error < StandardError; end

    def self.new(*args, store: Foxy::Cache::Store::Fs.new, namespace: nil, **kws)
      store = Foxy::Cache::Store::Namespace.new(namespace: namespace, store: store) if namespace
      Foxy::Cache::Manager.new(*args, store: store, **kws)
    end
  end
end

Dir["#{__dir__}/cache/**/*.rb"]
  .sort
  .each { |file| require file }
