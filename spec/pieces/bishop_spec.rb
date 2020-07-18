# frozen_string_literal: true

require_relative '../../lib/chess_pieces'
require_relative '../../lib/board'
require_relative 'shared_examples_for_pieces'

RSpec.describe Pieces::Bishop do
  describe '#valid_moves' do
    subject(:bishop) { described_class.new(position: position, player: :white) }

    context 'when in starting position' do
      it_behaves_like 'a piece that moves', 'b1', %w[a2 c2 d3 e4 f5 g6 h7]
    end

    context 'when in the middle of the board' do
      it_behaves_like 'a piece that moves', 'd4',
                      %w[a7 b6 c5 e5 f6 g7 h8 c3 b2 a1 e3 f2 g1]
    end

    # context 'when able to capture a piece' do
    #   it_behaves_like 'a piece that moves', 'a2', %w[a3 a4 b3], ['b3']
    # end

    # context 'when blocked by an opposing piece' do
    #   it_behaves_like 'a piece that moves', 'a2', [], ['a3']
    # end

    # context 'when one space is blocked' do
    #   it_behaves_like 'a piece that moves', 'a2', ['a3'], ['a4']
    # end

    # context 'when blocked but able to capture a piece' do
    #   it_behaves_like 'a piece that moves', 'b2', %w[b3 c3], %w[c3 b4]
    # end
  end
end
