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
    self.kings = pieces.map { |_, piece| piece if piece.class == Pieces::King }.compact
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
      update_board_capture(chess_move, final_position, piece)
    when :castle
      update_board_castle(chess_move, final_position, piece, orig_coords)
    else
      piece.move(final_position) { |new_position| board.move_piece(new_position, piece) }
      update_en_passant(orig_coords, piece)
    end
    promote(piece) if piece.promotable?
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

  # returns if the side of color is in check or now
  def check?(color)
    # moves that can capture by the opponent
    dangerous_moves = destinations_move_select do |move|
      move[:capturable]
    end[CConf.opponent(color)]
    !!dangerous_moves && !!dangerous_moves[king_locations[color]]
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

  def promote(piece)
    position = piece.position
    pieces[position] = Pieces::Queen.new(position: position, player: piece.player)
    board.set(position, pieces[position])
  end

  def update_en_passant(orig_coords, piece)
    # really smelly
    en_passant.each { |pawn| pawn.en_passant = nil }
    en_passant.clear
    return unless piece.is_a?(Pieces::Pawn)

    distance_traveled = (orig_coords.row - piece.coordinates.row).abs
    return unless distance_traveled == 2

    [[-1, 0], [1, 0]].each do |move|
      neighbor = board.at(piece.offset_position(move))
      # could move this into the pawn class
      if neighbor.is_a?(Pieces::Pawn) && neighbor.enemy?(piece)
        neighbor.en_passant = piece.position
        en_passant << neighbor
      end
    rescue IndexError
      next
    end
  end

  def update_board_capture(chess_move, piece_final_position, piece)
    captured_position = chess_move[:piece].position
    captured_piece = board.at(chess_move[:piece].position)
    captured_piece.move(nil) { board.set(captured_position, nil) }
    piece.move(piece_final_position) { |new_position| board.move_piece(new_position, piece) }
  end

  def update_board_castle(chess_move, piece_final_position, piece, orig_coords)
    piece.move(piece_final_position) { |new_position| board.move_piece(new_position, piece) }
    rook = board.at(chess_move[:piece].position)
    column_offset = orig_coords.column - piece.coordinates.column < 0 ? -1 : 1
    rook.move(piece.offset_position([column_offset, 0])) do |new_position|
      board.move_piece(new_position, rook)
    end
  end
end
