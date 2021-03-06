# frozen_string_literal: true

require_relative '../lib/board'
require_relative '../lib/piece'

RSpec.describe Board do
  describe '.dimensions' do
    subject(:board_dimensions) { described_class.new.dimensions }

    context 'when the board is standard a standard size' do
      let(:width) { CConf::BOARD_WIDTH }
      let(:height) { CConf::BOARD_HEIGHT }

      it { expect(board_dimensions).to eq [width, height] }
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

      it { expect { board.at(position) }.to raise_error IndexError }
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
      let(:column) { CConf::BOARD_WIDTH + 1 }
      let(:row) { CConf::BOARD_HEIGHT + 1 }

      it { expect { chess_notation }.to raise_error IndexError }
    end
  end

  describe '#set' do
    subject(:board) { described_class.new }

    context 'when given a valid position' do
      let(:piece) { instance_double('Piece') }

      let(:position) { 'B4' }

      it 'changes the board' do
        expect { board.set(position, piece) }.to change { board.at(position) }
          .from(nil).to piece
      end
    end

    context 'when given an invalid position' do
      let(:piece) { instance_double('Piece') }

      let(:position) { 'K9' }

      it 'changes the board' do
        expect { board.set(position, piece) }.to raise_error IndexError
      end
    end
  end
end
