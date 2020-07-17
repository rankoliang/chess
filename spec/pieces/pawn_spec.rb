# frozen_string_literal: true

require_relative '../../lib/chess_pieces'
require_relative '../../lib/board'

RSpec.describe Pieces::Pawn do
  describe '#valid_moves' do
    subject(:pawn) { described_class.new(position: position, player: :white) }

    context 'when in starting position' do
      let(:position) { 'a2' }

      it 'can move up to two spaces forward' do
        expect(pawn.valid_moves).to contain_exactly('a3', 'a4')
      end
    end

    RSpec.shared_examples 'movable piece' do |subject_position, opponent_positions, valid_moves|
      let(:position) { subject_position }
      let(:board) { Board.new }
      let(:defending_piece) { instance_double('Piece', player: :black) }
      let(:get_position) { proc { |position| board.at(position) } }

      before do
        allow(board).to receive(:at).and_call_original
        opponent_positions.each do |opp_pos|
          allow(board).to receive(:at).with(opp_pos).and_return(defending_piece)
        end
      end

      it do
        expect(pawn.valid_moves(&get_position))
          .to contain_exactly(*valid_moves)
      end
    end

    context 'when able to capture a piece' do
      it_behaves_like 'movable piece', 'a2', ['b3'], %w[a3 a4 b3]
    end

    context 'when blocked by an opposing piece' do
      it_behaves_like 'movable piece', 'a2', ['a3'], []
    end

    context 'when one space is blocked' do
      it_behaves_like 'movable piece', 'a2', ['a4'], ['a3']
    end

    context 'when blocked but able to capture a piece' do
      it_behaves_like 'movable piece', 'a2', %w[b3 a4], %w[a3 b3]
    end
  end
end
