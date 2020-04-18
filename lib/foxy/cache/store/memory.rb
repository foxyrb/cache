# frozen_string_literal: true

module Foxy
  module Cache
    module Store
      class Memory
        attr_reader :data

        def initialize(**_opts)
          @data = {}
        end

        def put(path, input)
          data[path] = input.to_s
        end

        def get(path)
          data[path]
        end

        def delete(path)
          data.delete_if { |k, _v| k =~ %r{^#{path}(/.*)?} }
        end
      end
    end
  end
end
