# frozen_string_literal: true

require_relative '../../lib/chess_pieces'
require_relative '../../lib/board'
require_relative 'shared_examples_for_pieces'

RSpec.describe Pieces::Pawn do
  describe '#valid_moves' do
    subject(:pawn) { described_class.new(position: position, player: :white) }

    context 'when in starting position' do
      let(:position) { 'a2' }

      it 'can move up to two spaces forward' do
        expect(pawn.valid_moves).to contain_exactly('a3', 'a4')
      end
    end

    context 'when able to capture a piece' do
      it_behaves_like 'a piece that moves', 'can capture diagonally',
                      'a2', expected_moves: %w[a3 a4 b3], enemies: %w[b3]
    end

    context 'when blocked by an opposing piece' do
      it_behaves_like 'a piece that moves', 'cannot move',
                      'a2', enemies: %w[a3]
    end

    context 'when one space is blocked' do
      it_behaves_like 'a piece that moves', 'can only move one space',
                      'a2', expected_moves: %w[a3], enemies: %w[a4]
    end

    context 'when blocked but able to capture a piece' do
      it_behaves_like 'a piece that moves', 'can only capture',
                      'b2', expected_moves: %w[b3 c3], enemies: %w[c3 b4]
    end
  end
end
