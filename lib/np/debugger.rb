module Np
  class Debugger
    NodePattern = ::RuboCop::AST::NodePattern

    attr_accessor :pattern, :ruby, :ruby_ast, :node_pattern

    def initialize(pattern:, ruby:)
      @pattern = pattern
      @ruby = ruby
      @pattern_error = nil
    end

    def ruby_ast
      @ruby_ast ||= begin
        buffer = ::Parser::Source::Buffer.new('(ruby)', source: ruby)
        builder = ::RuboCop::AST::Builder.new
        ::Parser::CurrentRuby.new(builder).parse(buffer)
      end
    end

    def node_pattern
      return if @pattern_error

      @node_pattern ||= NodePattern.new(pattern)
    rescue NodePattern::Invalid => e
      @pattern_error = e
      nil
    end

    def match_code
      node_pattern&.match_code
    end

    def ast_to_h
      return {} unless node_pattern

      export(colorizer.node_pattern.ast)
    end

    private

    def export(node)
      return node unless node.is_a?(NodePattern::Node)

      {
        type: node.type,
        matched: test.matched?(node),
        children: node.children.map { |c| export(c) }
      }
    end

    def colorizer
      @colorizer ||= NodePattern::Compiler::Debug::Colorizer.new(pattern)
    end

    def test
      @test ||= colorizer.test(ruby)
    end
  end
end
