module Np
  module Ext
    # Patch Builder to never optimize to sets. FIXME
    module NeverOptimizeToSets
      def matches_within_set?
        false
      end

      ::RuboCop::AST::NodePattern::Builder.prepend self
    end
  end
end
