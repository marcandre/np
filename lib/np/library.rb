# frozen_string_literal: true

module Np
  class Library < Struct.new(:path)
    def search(node_matcher, &block)
      Search.new(node_matcher: node_matcher, path: path, &block).perform
    end
  end
end

