# frozen_string_literal: true

require_relative '../../lib/chess_pieces'
require_relative '../../lib/board'
require_relative 'shared_examples_for_pieces'

RSpec.describe Pieces::Knight do
  describe '#valid_moves' do
    subject(:knight) { described_class.new(position: position, player: :white) }

    context 'when in starting position' do
      it_behaves_like 'a piece', that('moves in an l shape in some directions'),
                      'b1', expected_moves: %w[a3 c3], friendly: %w[d2]
    end

    # context 'when unblocked' do
    #   it_behaves_like 'a piece', that('moves in any direction'),
    #                   'd4', expected_moves: %w[c3 c4 c5 d3 d5 e3 e4 e5]
    # end

    # context 'when it can capture enemies' do
    #   it_behaves_like 'a piece', that('moves in any direction'),
    #                   'd4', expected_moves: %w[c3 c4 c5 d3 d5 e3 e4 e5],
    #                         enemies: %w[c5 e5]
    # end

    # context 'when blocked by friendly pieces' do
    #   it_behaves_like 'a piece', that('moves in some directions'),
    #                   'd4', expected_moves: %w[c3 c4 d3 d5 e3 e4],
    #                         friendly: %w[c5 e5]
    # end

    # context 'when it can capture and block' do
    #   it_behaves_like 'a piece', that('moves in some directions'),
    #                   'd4', expected_moves: %w[c3 c4 d3 d5 e3 e4],
    #                         friendly: %w[c5 e5], enemies: %w[c3 c4]
    # end
  end
end
