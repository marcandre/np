module Np
  class Debugger
    NodePattern = ::RuboCop::AST::NodePattern
    ALLOWED_FUNCTIONS = %i[respond_to? is_a? kind_of? instance_of? nil? eql?].to_set.freeze

    attr_accessor :pattern, :ruby, :ruby_ast, :node_pattern

    def initialize(pattern:, ruby:)
      @pattern = pattern
      @ruby = ruby
      @pattern_error = nil
    end

    def ruby_ast
      @ruby_ast ||= begin
        buffer = ::Parser::Source::Buffer.new('(ruby)', source: ruby)
        ruby_parser.parse(buffer)
      end
    end

    def ruby_parser
      builder = ::RuboCop::AST::Builder.new
      parser = ::Parser::CurrentRuby.new(builder)
      parser.diagnostics.all_errors_are_fatal = true
      parser
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

    # See https://github.com/syntax-tree/unist
    def node_pattern_to_unist
      return {} unless node_pattern

      node_to_unist(colorizer.node_pattern.ast)
    end

    def comments_to_unist
      comments = colorizer.compiler.comments.map do |comment|
        {
          type: :comment,
          matched: :comment,
          position: range_to_unist(comment.loc.expression)
        }
      end
      {
          type: :comment_list,
          children: comments,
      }
    end

    def test
      check_function_calls!
      @test ||= colorizer.test(ruby)
    end

    def matched?
      test.matched?(colorizer.node_pattern.ast).tap {|x| p 'mat', x}
    end

    def returned
      test.returned
    end

    private

    def check_function_calls!(allow_list = ALLOWED_FUNCTIONS)
      forbidden = colorizer.node_pattern.ast
        .each_node
        .select { |n| n.type == :function_call }
        .map(&:child)
        .grep_v(allow_list)

      unless forbidden.empty?
        raise "Forbidden function call: #{forbidden.join(', ')}. Acceptable calls: #{allow_list.to_a.join(', ')}"
      end
    end

    def element_to_unist(elem)
      return node_to_unist(elem) if elem.is_a?(NodePattern::Node)

      {
        type: elem.class.name.downcase,
        value: elem.inspect,
      }
    end

    BASIC_CLASSES = Set[NilClass, FalseClass, TrueClass, Integer, Float, Symbol, String].freeze
    private_constant :BASIC_CLASSES

    def node_to_unist(node)
      if node.children.size == 1 && BASIC_CLASSES.include?(node.child.class)
        data_kind = :value
        data = node.child
      else
        data_kind = :children
        data = node.children.map { |c| element_to_unist(c) }
      end

      {
        type: node.type,
        matched: test.matched?(node),
        position: range_to_unist(node.loc&.expression),
        data_kind => data
      }
    end

    def range_to_unist(range)
      return unless range

      {
        start: {
          line: range.line,
          column: range.column + 1,
          offset: range.begin_pos,
        },
        end: {
          line: range.last_line,
          column: range.last_column + 1,
          offset: range.end_pos,
        },
      }
    end

    def colorizer
      @colorizer ||= NodePattern::Compiler::Debug::Colorizer.new(pattern)
    end
  end
end
