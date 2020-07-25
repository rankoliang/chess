# frozen_string_literal: true

require_relative '../lib/move_validator'
require_relative '../lib/piece'

RSpec.describe MoveValidator do
  describe '#validate' do
    subject(:validator) { described_class.new(:Standard, :CONTINUE) }

    RSpec.shared_context 'validator' do |subject_position, player_color = :white, **positions|
      let(:position) { subject_position }
      let(:board) { Board.new }
      let(:piece_get) { proc { |position| board.at(position) } }
      let(:player_color) { player_color }

      before do
        allow(board).to receive(:at).and_call_original
        positions.default = []
        positions[:enemies].each do |position|
          defending_piece = instance_double('Piece', player: piece.enemy, position: position)
          allow(board).to receive(:at).with(position).and_return(defending_piece)
        end
        positions[:friendly].each do |position|
          friendly_piece = instance_double('Piece', player: piece.player, position: position)
          allow(board).to receive(:at).with(position).and_return(friendly_piece)
        end
      end
    end

    let(:piece) { Piece.new(position: position, player: player_color) }
    let(:valid_moves) { validator.validate(piece, moves, &piece_get) }

    # before { puts valid_moves }

    context 'when blocked by nothing' do
      include_context 'validator', 'a1'
      let(:moves) { (1..9).map { |i| [0, i] } }
      let(:move_list) { %w[a2 a3 a4 a5 a6 a7 a8] }

      it 'returns all moves' do
        expect(valid_moves).to eq(
          move_hash_generate(move_list, { type: :unblocked, piece: nil, level: 0 })
        )
      end
    end

    context 'when blocked by an enemy' do
      include_context 'validator', 'a1', friendly: %w[a5]

      let(:moves) { (1..8).map { |i| [0, i] } }
      let(:unblocked_move) { { type: :unblocked, piece: nil, level: 0 } }
      let(:blocked_move) { { type: :blocked, piece: piece_get.call('a5'), level: 1 } }

      it 'returns all moves' do
        expect(valid_moves).to eq(
          move_hash_generate(%w[a2 a3 a4], unblocked_move).merge(
            move_hash_generate(%w[a5 a6 a7 a8], blocked_move)
          )
        )
      end
    end
  end
end

def move_hash_generate(positions, move_info)
  positions.each_with_object({}) do |move, moves|
    moves[move] = move_info
  end
end
