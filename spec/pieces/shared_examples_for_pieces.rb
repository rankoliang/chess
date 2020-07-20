# frozen_string_literal: true

RSpec.shared_examples 'piece#valid_moves' do |expectation_message, subject_position, **positions|
  let(:position) { subject_position }
  let(:board) { Board.new }
  let(:defending_piece) { instance_double('Piece', player: :black) }
  let(:friendly_piece) { instance_double('Piece', player: :white) }
  let(:get_position) { proc { |position| board.at(position) } }

  before do
    allow(board).to receive(:at).and_call_original
    positions.default = []
    positions[:enemies].each do |opp_pos|
      allow(board).to receive(:at).with(opp_pos).and_return(defending_piece)
    end
    positions[:friendly].each do |friend_pos|
      allow(board).to receive(:at).with(friend_pos).and_return(friendly_piece)
    end
  end

  it expectation_message do
    expect(subject.valid_moves(&get_position))
      .to contain_exactly(*positions[:expected_moves])
  end
end

def that(expectation_message)
  expectation_message
end
