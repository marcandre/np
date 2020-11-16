# frozen_string_literal: true

require 'rubocop/ast'
require 'require_relative_dir'
using RequireRelativeDir

module Np
  NodePattern = ::RuboCop::AST::NodePattern

  def self.ruby_parser
    builder = ::RuboCop::AST::Builder.new
    parser = ::Parser::CurrentRuby.new(builder)
    parser.diagnostics.all_errors_are_fatal = true
    parser
  end

  require_relative_dir 'np/ext'
  require_relative_dir
end
