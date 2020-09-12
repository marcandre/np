require 'sinatra'
require 'sinatra/json'
require 'slim'
require 'rubocop-ast'
require 'parser/current'
require_relative '../../np'

get '/' do
  slim :home
end

post '/update' do
  h = params.to_h.transform_keys!(&:to_sym)
  @info = Np::Debugger.new(**h)
  html = %i[ruby_ast pattern_code].to_h do |id|
    [id, slim(id, layout: false)]
  end
  json({html: html, unist: @info.to_unist})
end
