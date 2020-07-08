# frozen_string_literal: true

require_relative '../lib/board.rb'

describe Board do
  describe '#size' do
    subject(:board_size) { described_class.new.size }

    context 'when the board is standard' do
      let(:width) { ChessConfig::BOARD_WIDTH }
      let(:height) { ChessConfig::BOARD_HEIGHT }

      it { expect(board_size).to eq [width, height] }
    end
  end
end
