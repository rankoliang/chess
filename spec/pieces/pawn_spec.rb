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
      let(:position) { 'a2' }

      context 'when a pawn is white' do
        subject(:pawn) { white_pawn }

        it 'can move up to two spaces forward' do
          expect(white_pawn.valid_moves).to contain_exactly('a3', 'a4')
        end
      end
    end

    context 'when the pawn is able to capture a piece' do
      context 'when a pawn is white' do
        subject(:pawn) { white_pawn }

        include_examples 'piece#valid_moves', that('can capture diagonally'),
                         'a2', expected_moves: %w[a3 a4 b3], enemies: %w[b3]
      end
    end

    context 'when the pawn is blocked by an opposing piece' do
      context 'when a pawn is white' do
        subject(:pawn) { white_pawn }

        include_examples 'piece#valid_moves', that('is blocked'),
                         'a2', enemies: %w[a3]
      end
    end

    context 'when the pawn is blocked by an friendly piece' do
      context 'when a pawn is white' do
        subject(:pawn) { white_pawn }

        include_examples 'piece#valid_moves', that('is blocked'),
                         'a2', friendly: %w[a3]
      end
    end

    context 'when one space is blocks a pawn' do
      context 'when a pawn is white' do
        subject(:pawn) { white_pawn }

        include_examples 'piece#valid_moves', that('can only move one space'),
                         'a2', expected_moves: %w[a3], enemies: %w[a4]
      end
    end

    context 'when a pawn is blocked but able to capture a piece' do
      context 'when a pawn is white' do
        subject(:pawn) { white_pawn }

        include_examples 'piece#valid_moves', that('can only capture'),
                         'b2', expected_moves: %w[b3 c3], enemies: %w[c3 b4]
      end
    end
  end
end
# rubocop:enable RSpec/NestedGroups
