# frozen_string_literal: true

require_relative '../../lib/chess_pieces'
require_relative '../../lib/board'
require_relative 'shared_examples_for_pieces'

RSpec.describe Pieces::Knight do
  describe '#valid_moves' do
    subject(:knight) { described_class.new(position: position, player: :white) }

    context 'when in starting position' do
      include_context 'piece#valid_moves', that('moves in an L shape in some directions'),
                      'b1', expected_moves: %w[a3 c3], friendly: %w[d2]
    end

    context 'when unblocked' do
      include_context 'piece#valid_moves', that('moves in an L shape in all directions'),
                      'd4', expected_moves: %w[b5 c6 e6 f5 f3 e2 c2 b3]
    end

    context 'when an enemy is at a valid move' do
      include_context 'piece#valid_moves', that('captures it'),
                      'd4', expected_moves: %w[b5 c6 e6 f5 f3 e2 c2 b3],
                            enemy: %w[c6 e6]
    end

    context 'when friendly pieces are blocking' do
      include_context 'piece#valid_moves', that('is blocked'),
                      'd4', expected_moves: %w[b5 f5 f3 e2 c2 b3],
                            friendly: %w[c6 e6]
    end

    context 'when is blocked and can capture' do
      include_context 'piece#valid_moves', that('is blocked'),
                      'd4', expected_moves: %w[b5 f5 f3 e2 c2 b3],
                            friendly: %w[c6 e6], enemy: %w[b5 c2]
    end
  end
end
