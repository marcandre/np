# frozen_string_literal: true
require 'rubocop/ast'
require 'require_relative_dir'
using RequireRelativeDir

module Np
  NodePattern = ::RuboCop::AST::NodePattern

  require_relative_dir 'np/ext'
  require_relative_dir
end
