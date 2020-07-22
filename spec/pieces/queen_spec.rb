# frozen_string_literal: true

require_relative '../../lib/chess_pieces'
require_relative '../../lib/board'
require_relative 'shared_examples_for_pieces'

RSpec.describe Pieces::Queen do
  describe '#valid_moves' do
    subject(:queen) { described_class.new(position: position, player: :white) }

    context 'when the queen is in the starting position' do
      include_examples 'piece#valid_moves', that('returns moves in some directions'),
                       'd1', expected_moves: %w[a1 b1 c1 e1 f1 g1 h1
                                                d2 d3 d4 d5 d6 d7 d8
                                                a4 b3 c2 e2 f3 g4 h5]
    end

    context 'when the queen is unblocked' do
      include_examples 'piece#valid_moves', that('returns moves in every direction'),
                       'd4', expected_moves: %w[d1 d2 d3 d5 d6 d7 d8
                                                a4 b4 c4 e4 f4 g4 h4
                                                a7 b6 c5 e3 f2 g1
                                                a1 b2 c3 e5 f6 g7 h8]
    end

    context 'when the queen can capture enemies' do
      include_examples 'piece#valid_moves', that('returns only unblocked moves'),
                       'd4', enemies: %w[d5 e5],
                             expected_moves: %w[d1 d2 d3 d5 a4 b4 c4 e4 f4 g4 h4
                                                a7 b6 c5 e3 f2 g1 a1 b2 c3 e5]
    end

    context 'when the queen is blocked by friendly pieces' do
      include_examples 'piece#valid_moves', that('returns only unblocked moves'),
                       'd4', friendly: %w[d5 e5],
                             expected_moves: %w[d1 d2 d3 a4 b4 c4 e4 f4 g4 h4
                                                a7 b6 c5 e3 f2 g1 a1 b2 c3]
    end

    context 'when the queen can capture and is blocked' do
      include_examples 'piece#valid_moves', that('returns only unblocked moves'),
                       'd4', friendly: %w[d5 e5], enemies: %w[c4 c3],
                             expected_moves: %w[d1 d2 d3 c4 e4 f4 g4 h4
                                                a7 b6 c5 e3 f2 g1 c3]
    end
  end
end
