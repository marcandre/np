require 'sinatra'
require 'sinatra/json'
require 'slim'
require 'rubocop-ast'
require 'parser/current'
require_relative '../lib/np'

get '/' do
  slim :home
end

post '/update' do
  h = params.to_h.transform_keys!(&:to_sym)
  @info = Np::Debugger.new(**h)
  begin
    html = %i[ruby_ast matches].to_h do |id|
      [id, slim(id, layout: false)]
    end
    json({
      html: html,
      node_pattern_unist: @info.node_pattern_to_unist,
      comments_unist: @info.comments_to_unist,
    })
  rescue Exception => e
    @error = e
    json({
      html: {matches: slim(:error, layout: false)},
    })
  end
end
