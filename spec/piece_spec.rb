# frozen_string_literal: true

require_relative '../lib/piece'
require_relative '../lib/chess_config'
require_relative '../lib/board'

RSpec.describe Piece do
  describe '#to_s' do
    subject(:piece) { described_class.new }

    it { expect(piece.to_s).to eq CConf::PIECE_SYMBOLS[:default] }
  end

  describe '#position' do
    context 'when a position is not given' do
      subject(:piece) { described_class.new }

      it { expect(piece.position).to be_nil }
    end

    context 'when a position is given' do
      subject(:piece) { described_class.new(position: 'B1') }

      it { expect(piece.position).to eq 'B1' }
    end
  end

  describe '#move' do
    subject(:piece) { described_class.new(position: original_position) }

    shared_examples 'position changes' do
      it {
        expect { piece.move(new_position, board) }.to change(piece, :position)
          .from(original_position).to new_position
      }
    end
    context 'when the piece is not on the board' do
      let(:original_position) { nil }
      let(:new_position) { 'D5' }
      let(:board) { Board.new }

      it do
        expect { piece.move(new_position, board) }
          .to(change { board.at(new_position) }.from(nil).to(piece))
      end

      include_examples 'position changes'
    end

    context 'when the piece is already on the board' do
      let(:original_position) { 'B1' }
      let(:new_position) { 'D5' }
      let(:board) { Board.new }

      before { board.set(original_position, piece) }

      it do
        expect { piece.move(new_position, board) }
          .to(change { board.at(original_position) }.from(piece).to(nil)
          .and(change { board.at(new_position) }.from(nil).to(piece)))
      end

      include_examples 'position changes'
    end
  end
end
