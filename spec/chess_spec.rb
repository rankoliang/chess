# frozen_string_literal: true

require_relative '../lib/chess'
require_relative '../lib/chess_config'

RSpec.describe Chess do
  describe '.initialize' do
    subject(:chess) { described_class.new }

    let(:board) { chess.board }

    it 'creates a non empty chess piece hash' do
      expect(chess.pieces.size).to eq 8 * 4
    end

    it 'creates a board non-empty board' do
      expect(board).not_to be_all(&:nil?)
    end

    it 'creates a board with dimensions 8 x 8' do
      expect(board.dimensions)
        .to eq [ChessConfig::BOARD_WIDTH, ChessConfig::BOARD_HEIGHT]
    end
  end

  describe '#move' do
    let(:chess) { described_class.new }

    context 'when there is a piece at the from location' do
      let(:board) { chess.board }
      let(:from) { 'a1' }
      let(:to) { 'c3' }

      before do
        allow(chess).to receive(:board).and_return(board)
      end

      it do
        expect { chess.move(from, to) }
          .to(change { board.at(from) }.to(nil)
          .and(change { board.at(to) }.from(nil).to(chess.pieces[from])))
      end

      it do
        expect { chess.move(from, to) }
          .to(change { chess.pieces[from] }.to(nil)
          .and(change { chess.pieces[to] }.from(nil)))
      end
    end

    context 'when there is not a piece at the from location' do
      let(:board) { chess.board }
      let(:from) { 'c3' }
      let(:to) { 'a1' }

      before do
        allow(chess).to receive(:board).and_return(board)
      end

      it do
        expect { chess.move(from, to) }
          .not_to(change { board.at(from) }.from(nil))
      end

      it do
        expect { chess.move(from, to) }
          .not_to(change { board.at(to) })
      end

      it do
        expect { chess.move(from, to) }
          .not_to(change { chess.pieces[from] }.from(nil))
      end

      it do
        expect { chess.move(from, to) }
          .not_to(change { chess.pieces[to] })
      end

      it { expect { chess.move(from, to) }.not_to(change { board }) }
    end

    context 'when the parameters are not valid' do
      let(:board) { chess.board }
      let(:from) { 'o3' }
      let(:to) { 'm9' }

      RSpec::Matchers.define_negated_matcher :not_change, :change

      it do
        expect { chess.move(from, to) }.to raise_error(IndexError)
          .and(not_change { board })
      end
    end
  end
end
