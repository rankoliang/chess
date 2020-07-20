# frozen_string_literal: true

require_relative '../../lib/chess_pieces'
require_relative '../../lib/board'
require_relative 'shared_examples_for_pieces'

RSpec.describe Pieces::Rook do
  describe '#valid_moves' do
    subject(:rook) { described_class.new(position: position, player: :white) }

    context 'when in starting position' do
      include_context 'piece#valid_moves', that('returns no moves'),
                      'a1', expected_moves: %w[], friendly: %w[a2 b1]
    end

    context 'when in the middle of the board' do
      include_context 'piece#valid_moves', that('returns moves in the cardinal directions'),
                      'd4', expected_moves: %w[d1 d2 d3 d5 d6 d7 d8 a4 b4 c4 e4 f4 g4 h4]
    end

    context 'when a piece can be captured' do
      include_context 'piece#valid_moves', that('returns some moved blocked'),
                      'd4', expected_moves: %w[d1 d2 d3 d5 d6 a4 b4 c4 e4 f4 g4 h4],
                            enemies: %w[d6]
    end

    context 'when blocked by a friendly unit' do
      include_context 'piece#valid_moves', that('returns some moved blocked'),
                      'd4', expected_moves: %w[d1 d2 d3 d5 a4 b4 c4 e4 f4 g4 h4],
                            friendly: %w[d6]
    end

    context 'when blocked by a friendly unit and can capture' do
      include_context 'piece#valid_moves', that('returns some moved blocked'),
                      'd4', expected_moves: %w[d1 d2 d3 d5 a4 b4 c4 e4],
                            friendly: %w[d6], enemies: %w[e4]
    end
  end
end
