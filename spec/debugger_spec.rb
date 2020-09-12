# frozen_string_literal: true

RSpec.describe Np::Debugger do
  let(:ruby) { 'bar' }
  let(:pattern) { '(send _ {:foo :bar :baz})' }
  subject(:debugger) { described_class.new(ruby: ruby, pattern: pattern) }

  describe 'ast_to_h' do
    it 'generates a big hash' do
      expect(debugger.ast_to_h).to match(hash_including(
        type: :sequence,
        matched: true,
        children: [
          hash_including(type: :node_type, children: [:send]),
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
