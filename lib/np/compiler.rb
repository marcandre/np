# frozen_string_literal: true

module Np
  class Compiler < NodePattern::Compiler::Debug
    class Trace < Trace
      NONE = Object.new.freeze

      def initialize
        @last_test = {}
        super
      end

      def enter(node_id, object = NONE)
        @last_test[node_id] = object
        super(node_id)
      end

      def last_test(node_id)
        r = @last_test.fetch(node_id, NONE)
        return yield if r == NONE

        r
      end
    end

    class Colorizer < Colorizer
      class Result < Result
        attr_accessor :other_matches

        # @return [Hash] a map for {node => tested object}
        def last_test_map
          @last_test_map ||=
            ast
              .each_node
              .to_h { |node| [node, tested(node)] }
        end

        # @return a value of `Trace#last_test`
        # yields if no last_test
        def last_test(node)
          id = colorizer.compiler.node_ids[node]
          trace.last_test(id) { yield if block_given? }
        end

        def unmatched_count
          ast = colorizer.node_pattern.ast
          return 0 if matched?(ast)

          # count "not matched" & "not visited" against the perfect score of 0
          match_map.values.reject(&:itself).size
        end
      end

      Compiler = Np::Compiler

      def test(ruby)
        ruby = ruby_ast(ruby) if ruby.is_a?(String)
        best, exact_matches = rank(results(ruby))
        best.other_matches = exact_matches - [best.ruby_ast]
        best
      end

      private def results(ruby)
        ruby.each_node.map do |ast|
          trace = Trace.new
          returned = @node_pattern.as_lambda.call(ast, trace: trace)
          Result.new(self, trace, returned, ast)
        end
      end

      # returns [best, exact_matches]
      private def rank(results)
        exact_matches = []
        best = results.min_by.with_index do |result, i|
          count = result.unmatched_count
          exact_matches << result.ruby_ast if count == 0
          [result.unmatched_count, i] # stable sort
        end
        [best, exact_matches]
      end
    end

    class NodePatternSubcompiler < NodePatternSubcompiler
      def tracer(kind)
        return super if kind == :success

        compiler.compiled_as_node_pattern << node
        "trace.#{kind}(#{node_id}, #{access_element})"
      end
    end

    attr_reader :compiled_as_node_pattern

    def initialize
      @compiled_as_node_pattern = Set[]
      super
    end
  end
end
