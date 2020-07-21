# frozen_string_literal: true

require_relative '../../lib/chess_pieces'
require_relative '../../lib/board'
require_relative 'shared_examples_for_pieces'

# rubocop:disable RSpec/NestedGroups
RSpec.describe Pieces::Pawn do
  describe '#valid_moves' do
    let(:white_pawn) { described_class.new(position: position, player: :white) }
    let(:black_pawn) { described_class.new(position: position, player: :black) }

    context 'when the pawn is in its starting position' do
      context 'when the pawn is white' do
        subject(:pawn) { white_pawn }

        let(:position) { 'a2' }

        it 'can move up to two spaces forward' do
          expect(pawn.valid_moves).to contain_exactly('a3', 'a4')
        end
      end

      context 'when the pawn is black' do
        subject(:pawn) { black_pawn }

        let(:position) { 'g7' }

        it 'can move up to two spaces forward' do
          expect(pawn.valid_moves).to contain_exactly('g6', 'g5')
        end
      end
    end

    context 'when the pawn is able to capture a piece' do
      context 'when the pawn is white' do
        subject(:pawn) { white_pawn }

        include_examples 'piece#valid_moves', that('can capture diagonally'),
                         'a2', expected_moves: %w[a3 a4 b3], enemies: %w[b3]
      end

      context 'when a pawn is black' do
        subject(:pawn) { black_pawn }

        include_examples 'piece#valid_moves', that('can capture diagonally'),
                         'g7', expected_moves: %w[g6 g5 f6], enemies: %w[f6]
      end
    end

    context 'when the pawn is blocked by an opposing piece' do
      context 'when the pawn is white' do
        subject(:pawn) { white_pawn }

        include_examples 'piece#valid_moves', that('is blocked'),
                         'a2', enemies: %w[a3]
      end

      context 'when a pawn is black' do
        subject(:pawn) { black_pawn }

        include_examples 'piece#valid_moves', that('is blocked'),
                         'g7', enemies: %w[g6]
      end
    end

    context 'when the pawn is blocked by an friendly piece' do
      context 'when the pawn is white' do
        subject(:pawn) { white_pawn }

        include_examples 'piece#valid_moves', that('is blocked'),
                         'a2', friendly: %w[a3]
      end

      context 'when a pawn is black' do
        subject(:pawn) { black_pawn }

        include_examples 'piece#valid_moves', that('is blocked'),
                         'g7', friendly: %w[g6]
      end
    end

    context 'when one space is blocks the pawn' do
      context 'when the pawn is white' do
        subject(:pawn) { white_pawn }

        include_examples 'piece#valid_moves', that('can only move one space'),
                         'a2', expected_moves: %w[a3], enemies: %w[a4]
      end

      context 'when a pawn is black' do
        subject(:pawn) { black_pawn }

        include_examples 'piece#valid_moves', that('can only move one space'),
                         'g7', expected_moves: %w[g6], enemies: %w[g5]
      end
    end

    context 'when the pawn is blocked and able to capture a piece' do
      context 'when the pawn is white' do
        subject(:pawn) { white_pawn }

        include_examples 'piece#valid_moves', that('can only capture'),
                         'b2', expected_moves: %w[b3 c3], enemies: %w[c3 b4]
      end

      context 'when the pawn is black' do
        subject(:pawn) { black_pawn }

        include_examples 'piece#valid_moves', that('can only capture'),
                         'g7', expected_moves: %w[g6 h6], enemies: %w[g5 h6]
      end
    end
  end
end
# rubocop:enable RSpec/NestedGroups
