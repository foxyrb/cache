# frozen_string_literal: true

require "multi_json"
require "yaml"

module Foxy
  module Cache
    class Manager
      ITSELF = :itself.to_proc.freeze
      MutexLocker = Hash.new { |h, k| h[k] = Mutex.new }.to_proc

      class Result
        attr_reader :metadata, :content
        def initialize(metadata, content)
          @metadata = metadata
          @content = content
        end

        def self.wrap(content)
          return content if content.is_a?(self)

          new({}, content)
        end
      end

      def fetch(*args, **params, &block)
        loop do
          result = do_fetch(args, **params, &block)
          next sleep(1) if result.metadata == :cant_lock

          return result.content
        end
      end

      attr_accessor :config

      def initialize(**config)
        @config = config
      end

      def do_fetch(key, store:, force_not_found: false, dumper: ITSELF, loader: ITSELF, ext: format, locker: nil, separator: "/", &block)
        key = clean_key(key).join(separator) + ".#{ext}"

        readed = force_not_found ? Result.new(:not_found, nil) : get(store, key, loader)

        return readed if readed.metadata != :not_found

        mutex = locker&.(key)

        return Result.new(:cant_lock, nil) if mutex && !mutex.try_lock

        content = put(store, key, {}, dumper, block)

        mutex&.unlock

        expand(content, loader)
      end

      def clean_key(key)
        ["", *key.map { |fragment| fragment.to_s.gsub(/[^a-z0-9\-]+/i, "_") }]
      end

      def get(store, key, loader)
        expand(store.get(key), loader)
      end

      def expand(content, loader)
        return Result.new(:not_found, nil) if content.nil? || content == ""

        metadata, content = content.split("\r\n---\r\n", 2)
        Result.new(YAML.safe_load(metadata), loader.(content))
      end

      def put(store, key, metadata, dumper, block)
        result = Result.wrap(block.(self))
        str = "#{YAML.dump(metadata)}\r\n---\r\n#{dumper.(result.content)}"

        store.put(key, str) if result.metadata != :no_cache

        str
      end

      def html(*args, **kws, &block)
        fetch(*args, **config, **config, **kws, ext: "html", &block)
      end

      def raw(*args, **kws, &block)
        fetch(*args, **config, **config, **kws, ext: "txt", &block)
      end

      def yaml(*args, **kws, &block)
        fetch(*args, **config, **config, **kws, ext: "yaml", dumper: YAML.method(:dump), loader: YAML.method(:load), &block)
      end

      def json(*args, **kws, &block)
        fetch(*args, **config, **config, **kws, ext: "json", dumper: MultiJson.method(:dump), loader: MultiJson.method(:load), &block)
      end

      def marshal(*args, **kws, &block)
        fetch(*args, **config, **config, **kws, ext: "bin", dumper: Marshal.method(:dump), loader: Marshal.method(:load), &block)
      end

      def result(metadata, content)
        Result.new(metadata, content)
      end

      # metadata:
      #   now:
      #   expires:
      #   serializer:
      #   compressor:
    end
  end
end

# semaphore = Mutex.new

# a = Thread.new {
#   semaphore.synchronize {
#     # access shared resource
#   }
# }

# b = Thread.new {
#   semaphore.synchronize {
#     # access shared resource
#   }
# }
