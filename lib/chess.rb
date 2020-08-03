# frozen_string_literal: true

require 'date'
require_relative 'chess_board'
require_relative 'chess_pieces'
require_relative 'player'
require_relative 'chess_config'

# Handles high level game objects
class Chess
  attr_reader :board, :pieces, :players, :kings, :moves, :destinations
  attr_accessor :light_weight, :en_passant
  def initialize(light_weight: false)
    generate_pieces
    self.kings = pieces.filter_map { |_, piece| piece if piece.class == Pieces::King }
    self.players = %i[white black].map do |player_color|
      Player.new(player_color)
    end
    self.board = ChessBoard.new(pieces)
    self.moves = []
    self.light_weight = light_weight
    self.en_passant = []
    generate_destinations unless light_weight
  end

  def move(chess_move, final_position)
    serialized_args = Marshal.dump([chess_move, final_position])
    piece = board.at(chess_move[:responding_piece].position)
    orig_coords = piece.coordinates
    case chess_move[:type]
    when :en_passant, :capture
      captured_position = chess_move[:piece].position
      captured_piece = board.at(chess_move[:piece].position)
      captured_piece.move(nil) { board.move_piece(captured_position, nil) }
      piece.move(final_position) { |new_position| board.move_piece(new_position, piece) }
    when :castle
      piece.move(final_position) { |new_position| board.move_piece(new_position, piece) }
      rook = board.at(chess_move[:piece].position)
      column_offset = orig_coords.column - piece.coordinates.column < 0 ? -1 : 1
      rook.move(piece.offset_position([column_offset, 0])) do |new_position|
        board.move_piece(new_position, rook)
      end
    else
      piece.move(final_position) { |new_position| board.move_piece(new_position, piece) }
      en_passant.each { |pawn| pawn.en_passant = nil }
      en_passant.clear
      if piece.is_a?(Pieces::Pawn)
        distance_traveled = (orig_coords.row - piece.coordinates.row).abs
        if distance_traveled == 2
          [[-1, 0], [1, 0]].each do |move|
            neighbor = board.at(piece.offset_position(move))
            if neighbor.is_a?(Pieces::Pawn) && neighbor.enemy?(piece)
              neighbor.en_passant = piece.position
              en_passant << neighbor
            end
          rescue IndexError
            next
          end
        end
    end
    end
    # TODO: set en_passant to adjacent pawns if a pawn makes a double move
    # reset en passants immediately before this step.
    update_pieces
    generate_destinations unless light_weight
    moves << serialized_args
  end

  def pieces_by_player(player)
    pieces.filter { |_, piece| piece.player == player }
  end

  def king_locations
    kings.map { |king| [king.player, king.position] }.to_h
  end

  def check?(color)
    dangerous_moves = destinations_move_select do |move|
      move[:capturable]
    end
    !!dangerous_moves[CConf.opponent(color)][king_locations[color]]
  end

  def show
    board.draw
  end

  def valid_moves(piece)
    piece.valid_moves { |position| board.at(position) }
  end

  def serialize_moves
    Marshal.dump(moves)
  end

  # Returns a new game where the last move is undone
  def undo
    return self.class.load_game(moves[0..-2]) if moves.length >= 1

    self
  end

  def self.load_game(moves)
    game = new(light_weight: true)
    moves.each { |move_args| game.move(*Marshal.load(move_args)) }
    game.light_weight = false
    game
  end

  def destinations_move_select(&move_filter)
    generate_destinations if light_weight || !destinations
    return destinations unless block_given?

    destinations.map do |player, dest|
      [player, dest.map do |position, moves|
        moves_by_opponent = moves.select(&move_filter)
        [position, moves_by_opponent.empty? ? nil : moves_by_opponent]
      end.to_h.compact]
    end.to_h
  end

  private

  attr_writer :pieces, :board, :players, :kings, :moves, :destinations

  # generates a hash where the key is a position and the value are the
  # moves that can act at that position
  def generate_destinations
    destinations_hash = Hash.new do |dest, player|
      dest[player] = Hash.new do |moves, position|
        moves[position] = []
      end
    end
    self.destinations = pieces.values.each_with_object(destinations_hash) do |piece, destinations|
      next unless piece.position

      piece.all_moves { |position| board.at(position) }.each do |position, move|
        destinations[move[:responding_piece].player][position] << move if move[:level].zero?
      end
    end
  end

  def generate_pieces
    self.pieces = CConf.nested_hash_expand(CConf::DEFAULT_LOCATIONS) .map do |player, piece, position|
      chess_piece = Pieces.const_get(piece) || Piece
      new_piece = chess_piece.new(position: position, player: player)
      [position, new_piece]
    end.to_h
  end

  def update_pieces
    self.pieces = pieces.values.map do |piece|
      [piece.position, piece] if piece.position
    end.compact.to_h
  end
end
