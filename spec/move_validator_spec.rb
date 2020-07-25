# frozen_string_literal: true

require_relative '../lib/move_validator'
require_relative '../lib/piece'

RSpec.describe MoveValidator do
  describe '#validate' do
    subject(:validator) { described_class.new(:Standard, :CONTINUE) }

    let(:piece) { Piece.new(position: position, player: player_color) }
    let(:valid_moves) { validator.validate(piece, moves, &piece_get) }

    let(:piece_get) do
      proc do |position|
        if friendly.include? position
          Piece.new(position: position, player: piece.player)
        elsif enemies.include? position
          Piece.new(position: position, player: piece.enemy)
        end
      end
    end

    # before { puts valid_moves }

    context 'when blocked by nothing' do
      let(:player_color) { :white }
      let(:position) { 'a1' }
      let(:moves) { (1..9).map { |i| [0, i] } }
      let(:friendly) { %w[] }
      let(:enemies) { %w[] }
      let(:move_list) { %w[a2 a3 a4 a5 a6 a7 a8] }

      it 'returns all moves' do
        expect(valid_moves).to eq(
          move_list.each_with_object({}) do |move, moves|
            moves[move] = { type: :unblocked, piece: nil, level: 0 }
          end
        )
      end
    end

    context 'when blocked by an enemy' do
      let(:player_color) { :white }
      let(:position) { 'a1' }
      let(:moves) { (1..8).map { |i| [0, i] } }
      let(:friendly) { %w[a5] }
      let(:enemies) { %w[] }
      let(:unblocked_move) { { type: :unblocked, piece: nil, level: 0 } }
      let(:blocked_move) { { type: :blocked, piece: piece_get.call('a5'), level: 1 } }

      it 'returns all moves' do
        expect(valid_moves).to eq(
          { 'a2' => unblocked_move,
            'a3' => unblocked_move,
            'a4' => unblocked_move,
            'a5' => blocked_move,
            'a6' => blocked_move,
            'a7' => blocked_move,
            'a8' => blocked_move }
        )
      end
    end
  end
end
