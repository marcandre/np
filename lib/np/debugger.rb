# frozen_string_literal: true

module Np
  class Debugger
    ALLOWED_FUNCTIONS = %i[respond_to? is_a? kind_of? instance_of? nil? eql?].to_set.freeze

    attr_accessor :pattern, :ruby

    def initialize(pattern:, ruby:)
      @pattern = pattern
      @ruby = ruby
      @pattern_error = nil
    end

    def ruby_ast
      @ruby_ast ||= begin
        processed_source = RuboCop::AST::ProcessedSource.new(ruby, RUBY_VERSION.to_f, '(ruby)')
        if !processed_source.valid_syntax?
          diagnostics = processed_source.diagnostics
          error = diagnostics.find { |d| d.level == :error } || diagnostics.first
          raise error.message
        end

        processed_source.ast
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
          position: range_to_unist(comment.loc.expression),
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
      test.matched?(colorizer.node_pattern.ast)
    end

    def returned
      test.returned
    end

    def best_match_to_unist
      range_to_unist(test.ruby_ast.loc&.expression)
    end

    def also_matched
      test.other_matches.map do |node|
        range_to_unist(node.loc&.expression)
      end
    end

    private def check_function_calls!(allow_list = ALLOWED_FUNCTIONS)
      forbidden = colorizer.node_pattern.ast
        .each_node
        .select { |n| n.type == :function_call }
        .map(&:child)
        .grep_v(allow_list)

      return if forbidden.empty?

      raise "Forbidden function call: #{forbidden.join(', ')}. Acceptable calls: #{allow_list.to_a.join(', ')}"
    end

    private def element_to_unist(elem)
      return node_to_unist(elem) if elem.is_a?(NodePattern::Node)

      {
        type: elem.class.name.downcase,
        value: elem.inspect,
      }
    end

    BASIC_CLASSES = Set[NilClass, FalseClass, TrueClass, Integer, Float, Symbol, String].freeze
    private_constant :BASIC_CLASSES

    private def node_to_unist(node)
      {
        type: node.type,
        matched: test.matched?(node),
        tested: last_test(node),
        position: range_to_unist(node.loc&.expression),
        **core_node_info(node),
      }
    end

    private def core_node_info(node)
      if node.children.size == 1 && BASIC_CLASSES.include?(node.child.class)
        { value: node.child }
      else
        { children: node.children.map { |c| element_to_unist(c) } }
      end
    end

    private def last_test(node)
      return unless colorizer.compiler.compiled_as_node_pattern.include?(node)

      last_test = test.last_test(node) { return }
      last_test.inspect
    end

    private def range_to_unist(range)
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

    private def colorizer
      @colorizer ||= Compiler::Colorizer.new(pattern)
    end
  end
end
