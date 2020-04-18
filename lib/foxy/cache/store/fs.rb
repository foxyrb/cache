# frozen_string_literal: true

module Foxy
  module Cache
    module Store
      class Fs
        def initialize(**opts); end

        def put(path, input)
          FileUtils.mkdir_p(File.dirname(path))
          File.open(path, "wb") { |f| f.write(input) }
        end

        def get(path)
          return unless File.exist?(path)

          File.open(path, "rb", &:read)
        end

        def delete(path)
          return unless File.exist?(path)
          return File.unlink(path) if File.ftype(path) == "file"
          return FileUtils.rm_rf(path) if File.ftype(path) == "directory"
        end
      end
    end
  end
end
