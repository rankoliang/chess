# frozen_string_literal: true

RSpec.shared_examples 'movable piece' do
  |subject_position, valid_moves, opponent_positions = [], friendly_positions = []|
  let(:position) { subject_position }
  let(:board) { Board.new }
  let(:defending_piece) { instance_double('Piece', player: :black) }
  let(:friendly_piece) { instance_double('Piece', player: :white) }
  let(:get_position) { proc { |position| board.at(position) } }

  before do
    allow(board).to receive(:at).and_call_original
    opponent_positions.each do |opp_pos|
      allow(board).to receive(:at).with(opp_pos).and_return(defending_piece)
    end
    friendly_positions.each do |friend_pos|
      allow(board).to receive(:at).with(friend_pos).and_return(friendly_piece)
    end
  end

  it do
    expect(subject.valid_moves(&get_position))
      .to contain_exactly(*valid_moves)
  end
end
