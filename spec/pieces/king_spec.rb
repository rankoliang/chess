# frozen_string_literal: true

require_relative '../../lib/chess_pieces'
require_relative '../../lib/board'
require_relative 'shared_examples_for_pieces'

RSpec.describe Pieces::King do
  describe '#valid_moves' do
    subject(:king) { described_class.new(position: position, player: :white) }

    context 'when in starting position' do
      it_behaves_like 'a piece that moves', that('moves in any direction'),
                      'd1', expected_moves: %w[c1 c2 d2 e2 e1]
    end

    # context 'when in the middle of the board' do
    #   it_behaves_like 'a piece that moves',
    #                   that('can move diagonally in all directions'),
    #                   'd4', expected_moves: %w[a7 b6 c5 e5 f6 g7 h8 c3 b2 a1 e3 f2 g1]
    # end

    # context 'when blocked by a friendly piece' do
    #   it_behaves_like 'a piece that moves',
    #                   that('cannot move past the friendly piece'),
    #                   'd4', expected_moves: %w[a7 b6 c5 e5 f6 g7 h8 e3 f2 g1], friendly: %w[c3]
    # end

    # context 'when able to capture a piece' do
    #   it_behaves_like 'a piece that moves',
    #                   that('cannot move past the captured piece'),
    #                   'd4', expected_moves: %w[c5 e5 f6 g7 h8 c3 b2 a1 e3 f2 g1],
    #                         enemies: %w[c5]
    # end

    # context 'when blocked and able to capture a piece' do
    #   it_behaves_like 'a piece that moves',
    #                   that('gets blocked appropriately'),
    #                   'd4', expected_moves: %w[c5 e5 f6 g7 h8 c3 b2 a1],
    #                         enemies: %w[c5], friendly: %w[e3]
    # end
  end
end
