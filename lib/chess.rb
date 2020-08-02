# frozen_string_literal: true

require 'date'
require_relative 'chess_board'
require_relative 'chess_pieces'
require_relative 'player'
require_relative 'chess_config'

# Handles high level game objects
class Chess
  attr_reader :board, :pieces, :players, :kings, :moves, :destinations
  def initialize
    generate_pieces
    self.kings = pieces.filter_map { |_, piece| piece if piece.class == Pieces::King }
    self.players = %i[white black].map do |player_color|
      Player.new(player_color)
    end
    self.board = ChessBoard.new(pieces)
    self.moves = []
    generate_destinations
  end

  def move(chess_move, final_position)
    serialized_args = Marshal.dump([chess_move, final_position])
    piece = board.at(chess_move[:responding_piece].position)
    orig_coords = piece.coordinates
    case chess_move[:type]
    when :en_passant, :capture
      captured_piece = board.at(chess_move[:piece].position)
      captured_piece.move(nil)
    when :castle
      rook = board.at(chess_move[:piece].position)
      column_offset = orig_coords.column - piece.coordinates.column < 0 ? -1 : 1
      rook.move(piece.offset_position([column_offset, 0])) do |new_position|
        board.move_piece(new_position, rook)
      end
    end
    piece.move(final_position) { |new_position| board.move_piece(new_position, piece) }
    # TODO: set en_passant to adjacent pawns if a pawn makes a double move
    # reset en passants immediately before this step.
    update_pieces
    generate_destinations
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
      move[:responding_piece] != color && move[:level] == 0 && move[:capturable]
    end
    !!dangerous_moves[king_locations[color]]
  end

  def show
    board.draw
  end

  def valid_moves(piece)
    piece.valid_moves { |position| board.at(position) }
  end

  def save_game(file_name, save_dir = CConf::SAVE_DIR)
    Dir.mkdir save_dir unless Dir.exist? save_dir
    File.open(File.join(save_dir, file_name), 'w') do |file|
      file.puts Marshal.dump(moves)
    end
    puts "Game saved to #{file_name}"
    file_name
  end

  # Returns a new game where the last move is undone
  def undo
    return self.class.replay_moves(moves[0..-2]) if moves.length >= 1

    self
  end

  def self.load_game(save_file)
    moves = Marshal.load(File.open(save_file, 'r').read)
    replay_moves(moves)
  end

  def self.replay_moves(moves)
    game = new
    moves.each { |move_args| game.move(*Marshal.load(move_args)) }
    game
  end

  def destinations_move_select(&move_filter)
    destinations.map do |position, moves|
      moves_by_opponent = moves.select(&move_filter)
      [position, moves_by_opponent.empty? ? nil : moves_by_opponent]
    end.to_h.compact
  end

  private

  attr_writer :pieces, :board, :players, :kings, :moves, :destinations

  # generates a hash where the key is a position and the value are the
  # moves that can act at that position
  def generate_destinations
    destinations_hash = Hash.new { |destinations, position| destinations[position] = [] }
    self.destinations = pieces.values.each_with_object(destinations_hash) do |piece, destinations|
      next unless piece.position

      piece.all_moves { |position| board.at(position) }.each do |position, move|
        destinations[position] << move
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
