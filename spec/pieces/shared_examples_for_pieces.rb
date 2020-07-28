# frozen_string_literal: true

RSpec.shared_examples 'piece#valid_moves' do |expectation_message, subject_position, **positions|
  context do
    let(:position) { subject_position }
    let(:board) { Board.new }
    let(:get_position) { proc { |position| board.at(position) } }

    before do
      allow(board).to receive(:at).and_call_original
      positions.default = []
      positions[:enemies].each do |position|
        defending_piece = instance_double('Piece', player: subject.enemy, position: position)
        allow(board).to receive(:at).with(position).and_return(defending_piece)
      end
      positions[:friendly].each do |position|
        friendly_piece = instance_double('Piece', player: subject.player, position: position)
        allow(board).to receive(:at).with(position).and_return(friendly_piece)
      end
      # puts subject.all_moves(&get_position)
    end

    it expectation_message do
      expect(subject.valid_moves(&get_position).keys)
        .to contain_exactly(*positions[:expected_moves])
    end
  end
end

def that(expectation_message)
  expectation_message
end
