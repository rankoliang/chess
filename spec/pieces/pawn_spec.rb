# frozen_string_literal: true

require_relative '../../lib/chess_pieces'
require_relative '../../lib/board'

RSpec.describe Pieces::Pawn do
  describe '#valid_moves' do
    subject(:pawn) { described_class.new(position: position) }

    context 'when in starting position' do
      let(:position) { 'a2' }

      it 'can move up to two spaces forward' do
        expect(pawn.valid_moves).to contain_exactly('a3', 'a4')
      end
    end

    context 'when able to capture a piece' do
      let(:position) { 'a2' }
      let(:board) { Board.new }
      let(:defending_piece) { instance_double('Piece', player: :black) }
      let(:get_position) { proc { |position| board.at(position) } }

      before do
        allow(board).to receive(:at).and_call_original
        allow(board).to receive(:at).with('b3').and_return(defending_piece)
      end

      it 'can move up to two spaces forward or take a piece' do
        expect(pawn.valid_moves(&get_position))
          .to contain_exactly('a3', 'a4', 'b3')
      end
    end
  end
end
