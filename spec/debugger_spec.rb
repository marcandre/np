# frozen_string_literal: true

RSpec.describe Np::Debugger do
  let(:ruby) { 'bar' }
  let(:pattern) { '(send _ {:foo :bar :baz})' }
  subject(:debugger) { described_class.new(ruby: ruby, pattern: pattern) }

  describe 'to_unist' do
    it 'generates a big hash' do
      expect(debugger.node_pattern_to_unist).to match(hash_including(
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
              hash_including(matched: false, tested: ':bar'),
              hash_including(matched: true),
              hash_including(matched: nil, tested: nil),
            ]
          )
        ]
      ))
    end

    context 'when the ruby code to match is partial' do
      let(:ruby) { 'def foo(a, b, c); a.bar; b.bar; c.bar; end' }

      it 'selects the first match' do
        expect(debugger.node_pattern_to_unist).to match(hash_including(
          type: :sequence,
          matched: true,
          children: [
            anything,
            hash_including(tested: 's(:lvar, :a)'),
            anything,
          ]
        ))
      end
    end

    context 'when the ruby code to match is partially matched' do
      let(:ruby) { 'def foo(a, b, c); a&.barx; b.barx; c.bar(42); end' }

      it 'selects the first match' do
        expect(debugger.node_pattern_to_unist).to match(hash_including(
          type: :sequence,
          matched: false,
          children: [
            anything,
            hash_including(tested: 's(:lvar, :b)'),
            anything,
          ]
        ))
      end
    end
  end

  describe 'test' do
    let(:pattern) { '(send _ #eval("puts :x"))' }

    it 'forbids most function calls' do
      expect { debugger.test }.to raise_error(/Forbidden function call: eval. Acceptable .* is_a?/)
    end
  end
end
