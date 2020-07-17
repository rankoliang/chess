# frozen_string_literal: true

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
    expect(subject.valid_moves(&get_position))
      .to contain_exactly(*valid_moves)
  end
end
