# frozen_string_literal: true

require_relative '../lib/chess'
require_relative '../lib/chess_config'

RSpec.describe Chess do
  describe '.initialize' do
    subject(:chess) { described_class.new }

    let(:board) { chess.board }

    it 'creates a non empty chess piece hash' do
      expect(chess.pieces.size).to eq CConf::BOARD_WIDTH * 4
    end

    it 'creates a board non-empty board' do
      expect(board).not_to be_all(&:nil?)
    end

    it 'creates a board with dimensions 8 x 8' do
      expect(board.dimensions)
        .to eq [CConf::BOARD_WIDTH, CConf::BOARD_HEIGHT]
    end

    it 'creates two players' do
      expect(chess.players.size).to eq 2
    end

    it 'creates two kings' do
      expect(chess.kings.size).to eq 2
    end
  end

  describe '#king_locations' do
    subject(:locations) { chess.king_locations }

    let(:chess) { described_class.new }

    it 'returns the king locations' do
      expect(locations).to contain_exactly [:white, 'e1'], [:black, 'e8']
    end
  end

  describe '#check?' do
    let(:chess) { described_class.new }

    context 'when the side is black' do
      it 'does not initially expect a check' do
        expect(chess).not_to be_check(:black)
      end
    end

    context 'when the side is white' do
      it 'does not initially expect a check' do
        expect(chess).not_to be_check(:white)
      end
    end

    context 'when the king is threatened' do
      let(:chess_move) { { type: :free, responding_piece: chess.board.at('d8') } }

      before { chess.move(chess_move, 'e2') }
      # before { chess.move('d8', 'e2') }

      it 'white expects a check' do
        expect(chess).to be_check(:white)
      end

      it 'black does not expect a check' do
        expect(chess).not_to be_check(:black)
      end
    end
  end

  describe '#move' do
    let(:chess) { described_class.new }

    let(:chess_move) do
      { type: move_type,
        responding_piece: chess.board.at(from),
        piece: chess.board.at(to) }
    end

    context 'when there is a piece at the from location' do
      let(:board) { chess.board }
      let(:from) { 'a1' }
      let(:to) { 'c3' }
      let(:move_type) { :free }

      before do
        allow(chess).to receive(:board).and_return(board)
      end

      it do
        expect { chess.move(chess_move, to) }
          .to(change { board.at(from) }.to(nil)
          .and(change { board.at(to) }.from(nil).to(chess.pieces[from])))
      end

      it do
        expect { chess.move(chess_move, to) }
          .to(change { chess.pieces[from] }.to(nil)
          .and(change { chess.pieces[to] }.from(nil)))
      end
    end
  end

  describe '#pieces_by_player' do
    let(:chess) { described_class.new }

    context 'when the player is :white' do
      let(:player) { :white }

      it do
        expect(chess.pieces_by_player(player).values).to all(have_attributes(player: player))
      end
    end

    context 'when the player is :black' do
      let(:player) { :black }

      it do
        expect(chess.pieces_by_player(player).values).to all(have_attributes(player: player))
      end
    end

    context 'when the player does not exist' do
      let(:player) { :blue }

      it do
        expect(chess.pieces_by_player(player)).to be_empty
      end
    end
  end
end
