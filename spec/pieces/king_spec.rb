# frozen_string_literal: true

require_relative '../../lib/chess_pieces'
require_relative '../../lib/board'
require_relative 'shared_examples_for_pieces'

RSpec.describe Pieces::King do
  describe '#valid_moves' do
    subject(:king) { described_class.new(position: position, player: :white) }

    context 'when in starting position' do
      include_examples 'piece#valid_moves', that('moves in some directions'),
                       'd1', expected_moves: %w[c1 c2 d2 e2 e1]
    end

    context 'when unblocked' do
      include_examples 'piece#valid_moves', that('moves in any direction'),
                       'd4', expected_moves: %w[c3 c4 c5 d3 d5 e3 e4 e5]
    end

    context 'when it can capture enemies' do
      include_examples 'piece#valid_moves', that('moves in any direction'),
                       'd4', expected_moves: %w[c3 c4 c5 d3 d5 e3 e4 e5],
                             enemies: %w[c5 e5]
    end

    context 'when blocked by friendly pieces' do
      include_examples 'piece#valid_moves', that('moves in some directions'),
                       'd4', expected_moves: %w[c3 c4 d3 d5 e3 e4],
                             friendly: %w[c5 e5]
    end

    context 'when it can capture and block' do
      include_examples 'piece#valid_moves', that('moves in some directions'),
                       'd4', expected_moves: %w[c3 c4 d3 d5 e3 e4],
                             friendly: %w[c5 e5], enemies: %w[c3 c4]
    end
  end
end
