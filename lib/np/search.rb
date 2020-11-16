# frozen_string_literal: true

module Np
  class Search < Struct.new(:directory, :node_matcher)
    Result = Struct.new(:node, :captures)

    def initialize(directory, node_matcher:)
      super(directory, node_matcher)
    end

    def perform(&block)
      return to_enum __callee__ unless block
      each_path do |path|
        ast = parse(path)
        search(ast, &block)
      end
    end

    private

    def each_path(&block)
      Dir.glob("#{directory}/**/*.rb").each(&block)
    end

    def parse(path)
      buffer = ::Parser::Source::Buffer.new(path).read
      Np.ruby_parser.parse(buffer)
    end

    def search(ast)
      ast.each_node do |node|
        yield node if node_matcher.call(node)
      end
    end
  end
end

