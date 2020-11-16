# frozen_string_literal: true

RSpec.describe Np::Search do
  let(:dir) { "#{__dir__}/fixtures/basic" }
  let(:pattern) { '{def defs}' }
  let(:matcher) { ::RuboCop::AST::NodePattern.new(pattern).as_lambda }
  subject(:search) { described_class.new(dir, node_matcher: matcher) }

  it 'does something useful' do
    expect { |b| search.perform(&b) }.to yield_successive_args(
      have_attributes(method_name: :foo),
      have_attributes(method_name: :bar)
    )
  end
end
