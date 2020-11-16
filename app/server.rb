# frozen_string_literal: true

require 'sinatra'
require 'sinatra/json'
require 'slim'
require 'yaml'
require_relative '../lib/np'

DOCS = YAML.load_file("#{__dir__}/docs.yaml").freeze

DOCS_URL = 'https://docs.rubocop.org/rubocop-ast/node_pattern.html'

module App
  refine Sinatra::Base do
    def params
      @params_cache ||= super.to_h.transform_keys!(&:to_sym)
    end
  end
end
using App

Faye::WebSocket.load_adapter('thin')

get '/' do
  @pattern = params[:p] || <<~PATTERN
    (send _receiver     # send nodes, to any receiver
     ${:foo :puts :bar} # with one of these method calls
     $...               # and any arguments
    )
  PATTERN

  @ruby = params[:ruby] || <<~RUBY
    def example
      puts :hello
      puts 'world'
    end
  RUBY
  slim :home
end

post '/update' do
  @info = Np::Debugger.new(**params)
  begin
    html = %i[ruby_ast matches].to_h do |id|
      [id, slim(id, layout: false)]
    end
    json({
      html: html,
      node_pattern_unist: @info.node_pattern_to_unist,
      comments_unist: @info.comments_to_unist,
      best_match: @info.best_match_to_unist,
      also_matched: @info.also_matched,
    })
  rescue StandardError => e
    @error = e
    json({
      html: { matches: slim(:error, layout: false) },
      exception: { message: e.message, trace: e.backtrace },
    })
  end
end

def library
  @library ||= Library.new("#{__dir__}/../vault")
end

post '/search' do
  if Faye::WebSocket.websocket?(request.env)
    ws = Faye::WebSocket.new(request.env)

    node_matcher = NodePattern.new(ws[:pattern]).as_lambda

    search = Thread.new do
      library.search(node_matcher) do |result|
        @result = result
        ws.send(slim(:result))
      end
    end

    ws.on(:close) do
      search.kill
    end

    ws.rack_response
  else
    raise NotImplementedError
  end
end
