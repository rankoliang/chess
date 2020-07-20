# frozen_string_literal: true

require_relative '../../lib/chess_pieces'
require_relative '../../lib/board'
require_relative 'shared_examples_for_pieces'

RSpec.describe Pieces::Bishop do
  describe '#valid_moves' do
    subject(:bishop) { described_class.new(position: position, player: :white) }

    context 'when in starting position' do
      include_context 'a piece', that('can move diagonally'),
                      'b1', expected_moves: %w[a2 c2 d3 e4 f5 g6 h7]
    end

    context 'when in the middle of the board' do
      include_context 'a piece',
                      that('can move diagonally in all directions'),
                      'd4', expected_moves: %w[a7 b6 c5 e5 f6 g7 h8 c3 b2 a1 e3 f2 g1]
    end

    context 'when blocked by a friendly piece' do
      include_context 'a piece',
                      that('cannot move past the friendly piece'),
                      'd4', expected_moves: %w[a7 b6 c5 e5 f6 g7 h8 e3 f2 g1], friendly: %w[c3]
    end

    context 'when able to capture a piece' do
      include_context 'a piece',
                      that('cannot move past the captured piece'),
                      'd4', expected_moves: %w[c5 e5 f6 g7 h8 c3 b2 a1 e3 f2 g1],
                            enemies: %w[c5]
    end

    context 'when blocked and able to capture a piece' do
      include_context 'a piece',
                      that('gets blocked appropriately'),
                      'd4', expected_moves: %w[c5 e5 f6 g7 h8 c3 b2 a1],
                            enemies: %w[c5], friendly: %w[e3]
    end
  end
end
