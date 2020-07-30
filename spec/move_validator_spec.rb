# frozen_string_literal: true

require_relative '../lib/move_validator'
require_relative '../lib/piece'
require_relative './helpers'
require_relative '../lib/chess_pieces'

RSpec.configure do |c|
  c.include Helpers
end

RSpec.describe MoveValidator do
  describe '#validate' do
    subject(:validator) { described_class.new(piece, :Standard, &piece_get) }

    let(:piece_get) { proc { |position| board.at(position) } }
    let(:unblocked_move) { { type: :free, piece: nil, level: 0, capturable: true, movable: true } }
    let(:piece) { Piece.new(position: position, player: player_color) }
    let(:valid_moves) { validator.validate(moves) }

    RSpec.shared_context 'when validating' do |subject_position, player_color = :white, **positions|
      let(:position) { subject_position }
      let(:board) { Board.new }
      let(:player_color) { player_color }

      before do
        allow(board).to receive(:at).and_call_original
        allow(board).to receive(:at).with(piece.position).and_return(piece)
        positions.default = []
        positions[:enemies].each do |position|
          defending_piece = instance_double('Piece', player: piece.enemy, position: position)
          allow(board).to receive(:at).with(position).and_return(defending_piece)
        end
        positions[:friendly].each do |position|
          friendly_piece = instance_double('Piece', player: piece.player, position: position)
          allow(board).to receive(:at).with(position).and_return(friendly_piece)
        end
      end
    end

    context 'when blocked by nothing' do
      include_context 'when validating', 'a1'
      let(:moves) { (1..9).map { |i| [0, i] } }
      let(:move_list) { %w[a2 a3 a4 a5 a6 a7 a8] }

      it 'returns all moves' do
        expect(valid_moves).to eq(
          move_hash_generate(move_list, { type: :free, piece: nil, level: 0, capturable: true, movable: true })
        )
      end
    end

    context 'when blocked by an friendly unit' do
      include_context 'when validating', 'a1', friendly: %w[a5]

      let(:moves) { (1..8).map { |i| [0, i] } }

      it 'returns all moves' do
        expect(valid_moves).to eq(
          move_hash_generate(%w[a2 a3 a4], unblocked_move).merge(
            { 'a5' => move(:blocked, 'a5', 1) }, move_hash_generate(%w[a6 a7 a8], move(:free, 'a5', 1))
          )
        )
      end
    end

    context 'when blocked by two friendly units' do
      include_context 'when validating', 'a1', friendly: %w[a5 a7]

      let(:moves) { (1..8).map { |i| [0, i] } }

      let(:expected_moves) do
        move_hash_generate(%w[a2 a3 a4], unblocked_move).merge(
          { 'a5' => move(:blocked, 'a5', 1),
            'a6' => move(:free, 'a5', 1),
            'a7' => move(:blocked, 'a7', 2),
            'a8' => move(:free, 'a7', 2) }
        )
      end

      it 'returns all moves' do
        expect(valid_moves).to eq(expected_moves)
      end
    end

    context 'when blocked by an enemy unit' do
      include_context 'when validating', 'a1', enemies: %w[a5]

      let(:moves) { (1..8).map { |i| [0, i] } }

      let(:expected_moves) do
        move_hash_generate(%w[a2 a3 a4], unblocked_move).merge(
          { 'a5' => move(:capture, 'a5', 0) },
          move_hash_generate(%w[a6 a7 a8], move(:free, 'a5', 1))
        )
      end

      it 'returns all moves' do
        expect(valid_moves).to eq(expected_moves)
      end
    end

    context 'when blocked by two enemy units' do
      include_context 'when validating', 'a1', enemies: %w[a5 a7]

      let(:moves) { (1..8).map { |i| [0, i] } }

      let(:expected_moves) do
        move_hash_generate(%w[a2 a3 a4], unblocked_move).merge(
          { 'a5' => move(:capture, 'a5', 0),
            'a6' => move(:free, 'a5', 1),
            'a7' => move(:capture, 'a7', 1),
            'a8' => move(:free, 'a7', 2) }
        )
      end

      it 'returns all moves' do
        expect(valid_moves).to eq(expected_moves)
      end
    end

    context 'when blocked by an enemy unit and a friendly unit' do
      include_context 'when validating', 'a1', enemies: %w[a5], friendly: %w[a7]

      let(:moves) { (1..8).map { |i| [0, i] } }

      let(:expected_moves) do
        move_hash_generate(%w[a2 a3 a4], unblocked_move).merge(
          { 'a5' => move(:capture, 'a5', 0),
            'a6' => move(:free, 'a5', 1),
            'a7' => move(:blocked, 'a7', 2),
            'a8' => move(:free, 'a7', 2) }
        )
      end

      it 'returns all moves' do
        expect(valid_moves).to eq(expected_moves)
      end
    end

    context 'when blocked by a friendly unit and an enemy unit' do
      include_context 'when validating', 'a1', enemies: %w[a7], friendly: %w[a5]

      let(:moves) { (1..8).map { |i| [0, i] } }

      let(:expected_moves) do
        move_hash_generate(%w[a2 a3 a4], unblocked_move).merge(
          { 'a5' => move(:blocked, 'a5', 1),
            'a6' => move(:free, 'a5', 1),
            'a7' => move(:capture, 'a7', 1),
            'a8' => move(:free, 'a7', 2) }
        )
      end

      it 'returns all moves' do
        expect(valid_moves).to eq(expected_moves)
      end
    end

    context 'when the blocking strategy is PawnMove' do
      context 'when blocked by an enemy unit' do
        subject(:validator) { described_class.new(piece, :PawnMove, &piece_get) }

        include_context 'when validating', 'a2', enemies: %w[a4]

        let(:moves) { (1..2).map { |i| [0, i] } }
        let(:unblocked_move) { { type: :free, piece: nil, level: 0, capturable: false, movable: true } }

        let(:expected_moves) do
          { 'a3' => unblocked_move,
            'a4' => move(:blocked, 'a4', 1, capturable: false, movable: true) }
        end

        it 'returns all moves' do
          expect(valid_moves).to eq(expected_moves)
        end
      end

      context 'when blocked by multiple units' do
        subject(:validator) { described_class.new(piece, :PawnMove, &piece_get) }

        include_context 'when validating', 'a2', enemies: %w[a3], friendly: %w[a4]

        let(:moves) { (1..2).map { |i| [0, i] } }
        let(:unblocked_move) { { type: :free, piece: nil, level: 0, capturable: false, movable: true } }

        let(:expected_moves) do
          { 'a3' => move(:blocked, 'a3', 1, capturable: false),
            'a4' => move(:blocked, 'a4', 2, capturable: false) }
        end

        it 'returns all moves' do
          expect(valid_moves).to eq(expected_moves)
        end
      end
    end

    context 'when the blocking strategy is PawnCapture' do
      context 'when blocked by an enemy unit' do
        subject(:validator) { described_class.new(piece, :PawnCapture, &piece_get) }

        include_context 'when validating', 'b2', enemies: %w[a3]

        let(:moves) { [[[-1, 1]], [[1, 1]]] }
        let(:unblocked_move) { { type: :free, piece: nil, level: 0, capturable: false, movable: true } }
        let(:valid_moves) do
          moves.reduce({}) { |valid_moves, path| valid_moves.merge(validator.validate(path)) }
        end

        let(:expected_moves) do
          { 'a3' => move(:capture, 'a3', 0, movable: false),
            'c3' => { type: :blocked, piece: nil,
                      level: 1, capturable: true, movable: false } }
        end

        it 'returns all moves' do
          expect(valid_moves).to eq(expected_moves)
        end
      end
    end

    context 'when the blocking strategy is EnPassant' do
      subject(:validator) { described_class.new(piece, :EnPassant, &piece_get) }

      include_context 'when validating', 'e5', enemies: %w[f5]

      let(:moves) { [[[-1, 1]], [[1, 1]]] }

      let(:valid_moves) do
        moves.reduce({}) { |valid_moves, path| valid_moves.merge(validator.validate(path)) }
      end
      let(:expected_moves) do
        { 'f6' => move(:en_passant, 'f5', 0, movable: false),
          'd6' => { type: :blocked, piece: nil,
                    level: 1, capturable: true, movable: false } }
      end
      let(:piece) { Pieces::Pawn.new(position: position, player: player_color) }

      before do
        piece.move(position)
        piece.en_passant = 'f5'
      end

      it 'returns all moves' do
        expect(valid_moves).to eq(expected_moves)
      end
    end

    context 'when the blocking strategy is :Castle' do
      subject(:validator) { described_class.new(piece, :Castle, &piece_get) }

      let(:valid_moves) { rooks.reduce({}) { |moves, rook| moves.merge(validator.validate(rook)) } }
      let(:piece) { Pieces::King.new(position: position, player: player_color) }

      context 'when the player color is white' do
        include_context 'when validating', 'e1', :white

        let(:rooks) { [['a1'], ['h1']] }
        let(:expected_moves) do
          { 'c1' => move(:castle, 'a1', 0, capturable: false),
            'g1' => move(:castle, 'h1', 0, capturable: false) }
        end

        before do
          rooks.flatten.each do |rook_position|
            friendly_rook = Pieces::Rook.new(position: rook_position, player: player_color)
            allow(board).to receive(:at).with(rook_position).and_return(friendly_rook)
          end
        end

        it 'returns available castles' do
          expect(valid_moves).to eq(expected_moves)
        end
      end

      context 'when the player color is black' do
        include_context 'when validating', 'e8', :black

        let(:rooks) { [['a8'], ['h8']] }
        let(:expected_moves) do
          { 'c8' => move(:castle, 'a8', 0, capturable: false),
            'g8' => move(:castle, 'h8', 0, capturable: false) }
        end

        before do
          rooks.flatten.each do |rook_position|
            friendly_rook = Pieces::Rook.new(position: rook_position, player: player_color)
            allow(board).to receive(:at).with(rook_position).and_return(friendly_rook)
          end
        end

        it 'returns available castles' do
          expect(valid_moves).to eq(expected_moves)
        end
      end

      context 'when a rook has moved' do
        include_context 'when validating', 'e8', :white

        let(:rooks) { [['a8'], ['h8']] }
        let(:expected_moves) do
          { 'c8' => move(:castle, 'a8', 0, capturable: false) }
        end

        before do
          rooks.flatten.each do |rook_position|
            friendly_rook = Pieces::Rook.new(position: rook_position, player: player_color)
            allow(board).to receive(:at).with(rook_position).and_return(friendly_rook)
          end
          board.at('h8').move('h8')
        end

        it 'returns available castles' do
          expect(valid_moves).to eq(expected_moves)
        end
      end

      context 'when both rooks have moved' do
        include_context 'when validating', 'e1', :white

        let(:rooks) { [['a1'], ['h1']] }

        before do
          rooks.flatten.each do |rook_position|
            friendly_rook = Pieces::Rook.new(position: rook_position, player: player_color)
            allow(board).to receive(:at).with(rook_position).and_return(friendly_rook)
          end
          board.at('h1').move('h1')
          board.at('a1').move('a1')
        end

        it 'returns available castles' do
          expect(valid_moves).to be_empty
        end
      end

      context 'when the king has moved' do
        include_context 'when validating', 'e1', :white

        let(:rooks) { [['a1'], ['h1']] }

        before do
          rooks.flatten.each do |rook_position|
            friendly_rook = Pieces::Rook.new(position: rook_position, player: player_color)
            allow(board).to receive(:at).with(rook_position).and_return(friendly_rook)
          end
          piece.move('e1')
        end

        it 'returns available castles' do
          expect(valid_moves).to be_empty
        end
      end

      context 'when a non-rook is at the position' do
        include_context 'when validating', 'e1', :white
        let(:valid_moves) { pieces.reduce({}) { |moves, piece| moves.merge(validator.validate(piece)) } }
        let(:expected_moves) do
          { 'c1' => move(:castle, 'a1', 0, capturable: false) }
        end

        let(:pieces) { [['a1'], ['h1']] }

        before do
          pieces.flatten.zip([Pieces::Rook, Pieces::Pawn]).each do |piece_position, piece_type|
            friendly_piece = piece_type.new(position: piece_position, player: player_color)
            allow(board).to receive(:at).with(piece_position).and_return(friendly_piece)
          end
        end

        it 'returns available castles' do
          expect(valid_moves).to eq(expected_moves)
        end
      end
    end
  end
end
