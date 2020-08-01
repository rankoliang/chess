# frozen_string_literal: true

require_relative '../../lib/chess_pieces'
require_relative '../../lib/board'
require_relative 'shared_examples_for_pieces'

# rubocop:disable RSec/NestedGroups
RSpec.describe Pieces::Pawn do
  describe '#valid_moves.keys' do
    let(:white_pawn) { described_class.new(position: position, player: :white) }
    let(:black_pawn) { described_class.new(position: position, player: :black) }

    context 'when the pawn is in its starting position' do
      context 'when the pawn is white' do
        subject(:pawn) { white_pawn }

        let(:position) { 'a2' }

        it 'returns two moves' do
          expect(pawn.valid_moves.keys).to contain_exactly('a3', 'a4')
        end
      end

      context 'when the pawn is black' do
        subject(:pawn) { black_pawn }

        let(:position) { 'g7' }

        it 'returns two moves' do
          expect(pawn.valid_moves.keys).to contain_exactly('g6', 'g5')
        end
      end
    end

    context 'when the pawn has moved' do
      context 'when the pawn is white' do
        subject(:pawn) { white_pawn }

        let(:position) { 'a3' }

        before { pawn.move(position) }

        it 'returns one move' do
          expect(pawn.valid_moves.keys).to contain_exactly('a4')
        end
      end

      context 'when the pawn is black' do
        subject(:pawn) { black_pawn }

        let(:position) { 'g6' }

        before { pawn.move(position) }

        it 'returns one move' do
          expect(pawn.valid_moves.keys).to contain_exactly('g5')
        end
      end
    end

    context 'when the pawn is able to capture a piece' do
      context 'when the pawn is white' do
        subject(:pawn) { white_pawn }

        include_examples 'piece#valid_moves', that('returns diagonal captures'),
                         'a2', expected_moves: %w[a3 a4 b3], enemies: %w[b3]
      end

      context 'when a pawn is black' do
        subject(:pawn) { black_pawn }

        include_examples 'piece#valid_moves', that('returns diagonal captures'),
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

        include_examples 'piece#valid_moves', that('returns unblocked moves'),
                         'a2', expected_moves: %w[a3], enemies: %w[a4]
      end

      context 'when a pawn is black' do
        subject(:pawn) { black_pawn }

        include_examples 'piece#valid_moves', that('returns unblocked moves'),
                         'g7', expected_moves: %w[g6], enemies: %w[g5]
      end
    end

    context 'when the pawn is blocked and able to capture a piece' do
      context 'when the pawn is white' do
        subject(:pawn) { white_pawn }

        include_examples 'piece#valid_moves', that('returns unblocked moves'),
                         'b2', expected_moves: %w[b3 c3], enemies: %w[c3 b4]
      end

      context 'when the pawn is black' do
        subject(:pawn) { black_pawn }

        include_examples 'piece#valid_moves', that('returns unblocked moves'),
                         'g7', expected_moves: %w[g6 h6], enemies: %w[g5 h6]
      end
    end

    context 'when pawn can en-passant' do
      context 'when a black pawn can en passant to the right' do
        subject(:pawn) { black_pawn }

        before do
          black_pawn.move(position)
          pawn.en_passant = 'd4'
        end

        include_examples 'piece#valid_moves', that('returns unblocked moves'),
                         'c4', expected_moves: %w[c3 d3], enemies: %w[b4 d4]

        include_examples 'piece#valid_moves', that('returns unblocked moves'),
                         'c4', expected_moves: %w[c3 d3], enemies: %w[c2 d4]

        include_examples 'piece#valid_moves', that('returns unblocked moves'),
                         'c4', expected_moves: %w[d3], enemies: %w[c3 b4 d4]
      end

      context 'when a black pawn can en passant to left' do
        subject(:pawn) { black_pawn }

        before do
          black_pawn.move(position)
          pawn.en_passant = 'b4'
        end

        include_examples 'piece#valid_moves', that('returns unblocked moves'),
                         'c4', expected_moves: %w[c3 b3], enemies: %w[c2 b4]

        include_examples 'piece#valid_moves', that('returns unblocked moves'),
                         'c4', expected_moves: %w[c3 b3], enemies: %w[c4 b4]

        include_examples 'piece#valid_moves', that('returns unblocked moves'),
                         'c4', expected_moves: %w[b3], enemies: %w[c4 c3 b4]
      end

      context 'when a white pawn can en passant to the right' do
        subject(:pawn) { white_pawn }

        before do
          pawn.move(position)
          pawn.en_passant = 'e5'
        end

        include_examples 'piece#valid_moves', that('returns unblocked moves'),
                         'd5', expected_moves: %w[e6 d6], enemies: %w[e5]

        include_examples 'piece#valid_moves', that('returns unblocked moves'),
                         'd5', expected_moves: %w[e6 d6], enemies: %w[c5 e5]

        include_examples 'piece#valid_moves', that('returns unblocked moves'),
                         'd5', expected_moves: %w[e6], enemies: %w[d6 e5]
      end

      context 'when a white pawn can en passant to left' do
        subject(:pawn) { white_pawn }

        before do
          pawn.move(position)
          pawn.en_passant = 'c5'
        end

        include_examples 'piece#valid_moves', that('returns unblocked moves'),
                         'd5', expected_moves: %w[c6 d6], enemies: %w[c5]

        include_examples 'piece#valid_moves', that('returns unblocked moves'),
                         'd5', expected_moves: %w[c6 d6], enemies: %w[c5 e5]

        include_examples 'piece#valid_moves', that('returns unblocked moves'),
                         'd5', expected_moves: %w[c6], enemies: %w[c5 e5 d6]

        include_examples 'piece#valid_moves', that('returns unblocked moves'),
                         'd5', expected_moves: %w[c6 e6], enemies: %w[c5 e5 d6 e6]
      end
    end
  end
end
# rubocop:disable Lint/RedundantCopEnableDirective
# rubocop:enable RSpec/NestedGroups
# rubocop:enable Lint/RedundantCopEnableDirective
