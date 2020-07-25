# frozen_string_literal: true

require_relative '../lib/move_validator'
require_relative '../lib/piece'

RSpec.describe MoveValidator do
  describe '#validate' do
    subject(:validator) { described_class.new(:Standard, :CONTINUE) }

    let(:piece) { Piece.new(position: 'a1', player: :white) }
    let(:moves) { (1..9).map { |i| [0, i] } }
    let(:valid_moves) { validator.validate(piece, moves, &piece_get) }

    let(:piece_get) do
      proc do |position|
        Piece.new(position: position, player: :black) if %w[].include? position
      end
    end

    it { expect(valid_moves.keys).to eq(%w[a2 a3 a4 a5 a6 a7 a8]) }
  end
end
