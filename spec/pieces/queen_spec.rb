# frozen_string_literal: true

require_relative '../../lib/chess_pieces'
require_relative '../../lib/board'
require_relative 'shared_examples_for_pieces'

RSpec.describe Pieces::Queen do
  describe '#valid_moves' do
    subject(:queen) { described_class.new(position: position, player: :white) }

    context 'when the queen is in the starting position' do
      include_examples 'piece#valid_moves', that('moves in some directions'),
                       'd1', expected_moves: %w[a1 b1 c1 e1 f1 g1 h1
                                                d2 d3 d4 d5 d6 d7 d8
                                                a4 b3 c2 e2 f3 g4 h5]
    end

    # TODO: change from expected moves for king to queen
    # context 'when the queen is unblocked' do
    #   include_examples 'piece#valid_moves', that('moves in any direction'),
    #                    'd4', expected_moves: %w[c3 c4 c5 d3 d5 e3 e4 e5]
    # end

    # context 'when the queen can capture enemies' do
    #   include_examples 'piece#valid_moves', that('moves in any direction'),
    #                    'd4', expected_moves: %w[c3 c4 c5 d3 d5 e3 e4 e5],
    #                          enemies: %w[c5 e5]
    # end

    # context 'when the queen is blocked by friendly pieces' do
    #   include_examples 'piece#valid_moves', that('moves in some directions'),
    #                    'd4', expected_moves: %w[c3 c4 d3 d5 e3 e4],
    #                          friendly: %w[c5 e5]
    # end

    # context 'when the queen can capture and block' do
    #   include_examples 'piece#valid_moves', that('moves in some directions'),
    #                    'd4', expected_moves: %w[c3 c4 d3 d5 e3 e4],
    #                          friendly: %w[c5 e5], enemies: %w[c3 c4]
    # end
  end
end
