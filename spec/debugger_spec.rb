# frozen_string_literal: true

RSpec.describe Np::Debugger do
  let(:ruby) { 'bar' }
  let(:pattern) { '(send _ {:foo :bar :baz})' }
  subject(:debugger) { described_class.new(ruby: ruby, pattern: pattern) }

  describe 'to_unist' do
    it 'generates a big hash' do
      expect(debugger.to_unist).to match(hash_including(
        type: :sequence,
        matched: true,
        position: {
          start: {line: 1, column: 1, offset: 0},
          end: {line: 1, column: 26, offset: 25},
        },
        children: [
          hash_including(type: :node_type, value: :send),
          hash_including(type: :wildcard),
          hash_including(
            type: :union,
            matched: true,
            children: [
              hash_including(matched: false),
              hash_including(matched: true),
              hash_including(matched: nil),
            ]
          )
        ]
      ))
    end
  end
end
