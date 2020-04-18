# frozen_string_literal: true

module Foxy
  module Cache
    module Store
      class Namespace
        def initialize(store:, namespace:, **_opts)
          @store = store
          @namespace = namespace
        end

        def put(path, input)
          @store.put("#{@namespace}#{path}", input)
        end

        def get(path)
          @store.get("#{@namespace}#{path}")
        end

        def delete(path)
          @store.delete("#{@namespace}#{path}")
        end
      end
    end
  end
end
