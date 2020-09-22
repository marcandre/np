module Np
  module Ext
    # Patch Builder to never optimize to sets. FIXME
    module NeverOptimizeToSets
      def set_optimizable?(*)
        false
      end

      ::RuboCop::AST::NodePattern::Builder.prepend self
    end
  end
end
