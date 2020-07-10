# frozen_string_literal: true

require_relative('../lib/piece')
require_relative('../lib/chess_config.rb')

RSpec.describe Piece do
  describe '#to_s' do
    subject(:piece) { Piece.new }

    it { expect(piece.to_s).to eq ChessConfig::PIECE_SYMBOLS[:default] }
  end

  describe '#position' do
    context 'when a position is not given' do
      subject(:piece) { Piece.new }

      it { expect(piece.position).to be_nil }
    end

    context 'when a position is given' do
      subject(:piece) { Piece.new(position: [0, 1]) }

      it { expect(piece.position).to eq [0, 1] }
    end
  end

  describe '.from_chess_notation' do
    subject(:piece) { Piece.from_chess_notation(position: 'B1') }

    it 'returns a piece with an array position' do
      expect(piece.position).to eq [1, 0]
    end
  end
end
