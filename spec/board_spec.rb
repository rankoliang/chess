# frozen_string_literal: true

require_relative '../lib/board.rb'

describe Board do
  describe '.size' do
    subject(:board_size) { described_class.new.size }

    context 'when the board is standard a standard size' do
      let(:width) { ChessConfig::BOARD_WIDTH }
      let(:height) { ChessConfig::BOARD_HEIGHT }

      it { expect(board_size).to eq [width, height] }
    end
  end

  describe '#at' do
    subject(:board) { described_class.new }

    before do
      # set 'c4' to 24
      board[3][2] = 24
    end

    context 'when a position is given' do
      let(:position) { 'c4' }

      it 'will return the correct piece' do
        expect(board.at(position)).to eq 24
      end
    end

    context 'when the column is uppercase' do
      let(:position) { 'C4' }

      it 'will return the correct piece' do
        expect(board.at(position)).to eq 24
      end
    end

    context 'when the position is out of bounds' do
      let(:position) { 'Z8' }

      it { expect(board.at(position)).to be_nil }
    end
  end

  describe '.chess_notation' do
    subject(:chess_notation) { described_class.chess_notation(column, row) }

    describe 'when the indices are valid' do
      let(:column) { 0 }
      let(:row) { 0 }

      it 'converts the given indices to chess notation' do
        expect(chess_notation).to eq 'a1'
      end
    end

    describe 'when the indices are not valid' do
      let(:column) { ChessConfig::BOARD_WIDTH + 1 }
      let(:row) { ChessConfig::BOARD_HEIGHT + 1 }

      it { expect(chess_notation).to be_nil }
    end
  end
end