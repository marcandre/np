# frozen_string_literal: true
require 'rubocop/ast'

module Np
  NodePattern = ::RuboCop::AST::NodePattern

  require_relative 'np/version'
  require_relative 'np/ext/builder'
  require_relative 'np/debugger'
  require_relative 'np/compiler'
end
