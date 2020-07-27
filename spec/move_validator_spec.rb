# frozen_string_literal: true

require_relative '../lib/move_validator'
require_relative '../lib/piece'
require_relative './helpers'

RSpec.configure do |c|
  c.include Helpers
end

RSpec.describe MoveValidator do
  describe '#validate' do
    subject(:validator) { described_class.new(:Standard) }

    let(:unblocked_move) { { type: :free, piece: nil, level: 0, capturable: true, movable: true } }
    let(:piece) { Piece.new(position: position, player: player_color) }
    let(:valid_moves) { validator.validate(piece, moves, &piece_get) }

    RSpec.shared_context 'when validating' do |subject_position, player_color = :white, **positions|
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

    # before { puts valid_moves }

    context 'when blocked by nothing' do
      include_context 'when validating', 'a1'
      let(:moves) { (1..9).map { |i| [0, i] } }
      let(:move_list) { %w[a2 a3 a4 a5 a6 a7 a8] }

      it 'returns all moves' do
        expect(valid_moves).to eq(
          move_hash_generate(move_list, { type: :free, piece: nil, level: 0, capturable: true, movable: true })
        )
      end
    end

    context 'when blocked by an friendly unit' do
      include_context 'when validating', 'a1', friendly: %w[a5]

      let(:moves) { (1..8).map { |i| [0, i] } }

      it 'returns all moves' do
        expect(valid_moves).to eq(
          move_hash_generate(%w[a2 a3 a4], unblocked_move).merge(
            { 'a5' => move(:blocked, 'a5', 1) }, move_hash_generate(%w[a6 a7 a8], move(:free, 'a5', 1))
          )
        )
      end
    end

    context 'when blocked by two friendly units' do
      include_context 'when validating', 'a1', friendly: %w[a5 a7]

      let(:moves) { (1..8).map { |i| [0, i] } }

      let(:expected_moves) do
        move_hash_generate(%w[a2 a3 a4], unblocked_move).merge(
          { 'a5' => move(:blocked, 'a5', 1),
            'a6' => move(:free, 'a5', 1),
            'a7' => move(:blocked, 'a7', 2),
            'a8' => move(:free, 'a7', 2) }
        )
      end

      it 'returns all moves' do
        expect(valid_moves).to eq(expected_moves)
      end
    end

    context 'when blocked by an enemy unit' do
      include_context 'when validating', 'a1', enemies: %w[a5]

      let(:moves) { (1..8).map { |i| [0, i] } }

      let(:expected_moves) do
        move_hash_generate(%w[a2 a3 a4], unblocked_move).merge(
          { 'a5' => move(:capture, 'a5', 0) },
          move_hash_generate(%w[a6 a7 a8], move(:free, 'a5', 1))
        )
      end

      it 'returns all moves' do
        expect(valid_moves).to eq(expected_moves)
      end
    end

    context 'when blocked by two enemy units' do
      include_context 'when validating', 'a1', enemies: %w[a5 a7]

      let(:moves) { (1..8).map { |i| [0, i] } }

      let(:expected_moves) do
        move_hash_generate(%w[a2 a3 a4], unblocked_move).merge(
          { 'a5' => move(:capture, 'a5', 0),
            'a6' => move(:free, 'a5', 1),
            'a7' => move(:capture, 'a7', 1),
            'a8' => move(:free, 'a7', 2) }
        )
      end

      it 'returns all moves' do
        expect(valid_moves).to eq(expected_moves)
      end
    end

    context 'when blocked by an enemy unit and a friendly unit' do
      include_context 'when validating', 'a1', enemies: %w[a5], friendly: %w[a7]

      let(:moves) { (1..8).map { |i| [0, i] } }

      let(:expected_moves) do
        move_hash_generate(%w[a2 a3 a4], unblocked_move).merge(
          { 'a5' => move(:capture, 'a5', 0),
            'a6' => move(:free, 'a5', 1),
            'a7' => move(:blocked, 'a7', 2),
            'a8' => move(:free, 'a7', 2) }
        )
      end

      it 'returns all moves' do
        expect(valid_moves).to eq(expected_moves)
      end
    end

    context 'when blocked by a friendly unit and an enemy unit' do
      include_context 'when validating', 'a1', enemies: %w[a7], friendly: %w[a5]

      let(:moves) { (1..8).map { |i| [0, i] } }

      let(:expected_moves) do
        move_hash_generate(%w[a2 a3 a4], unblocked_move).merge(
          { 'a5' => move(:blocked, 'a5', 1),
            'a6' => move(:free, 'a5', 1),
            'a7' => move(:capture, 'a7', 1),
            'a8' => move(:free, 'a7', 2) }
        )
      end

      it 'returns all moves' do
        expect(valid_moves).to eq(expected_moves)
      end
    end
  end
end
