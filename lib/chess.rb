# frozen_string_literal: true

require 'date'
require_relative 'chess_board'
require_relative 'chess_pieces'
require_relative 'player'
require_relative 'chess_config'

# Handles high level game objects
class Chess
  attr_reader :board, :pieces, :players, :kings, :moves, :attacking
  def initialize
    generate_pieces
    self.kings = pieces.filter_map { |_, piece| piece if piece.class == Pieces::King }
    self.players = %i[white black].map do |player_color|
      Player.new(player_color)
    end
    self.board = ChessBoard.new(pieces)
    self.moves = []
    generate_attacking
  end

  def move(from, to)
    piece = board.at(from)
    return false unless piece

    if to
      piece.move(to) { |new_position| board.move_piece(new_position, piece) }
    else
      piece.move(nil)
    end

    update_pieces(from, to, piece)
    generate_attacking
    moves << [from, to]
  end

  def pieces_by_player(player)
    pieces.filter { |_, piece| piece.player == player }
  end

  def king_locations
    kings.map { |king| [king.player, king.position] }.to_h
  end

  def check?(color)
    attacking[king_locations[color]].any? { |move| move[:level] == 0 }
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
    puts "Game saved to #{save_file_name}"
    save_file_name
  end

  def self.load_game(save_file)
    game = new
    moves = Marshal.load(File.open(save_file, 'r').read)
    moves.each { |from, to| game.move(from, to) }
    game
  end

  private

  attr_writer :pieces, :board, :players, :kings, :moves, :attacking

  # generates a hash where the key is a position and the value are the
  # moves that are attacking it
  def generate_attacking(attacking_pieces = pieces.values)
    attacking_hash = Hash.new { |attacking, position| attacking[position] = [] }
    self.attacking = attacking_pieces.each_with_object(attacking_hash) do |piece, attacking|
      piece.all_moves { |position| board.at(position) }.each do |position, move|
        attacking[position] << move if move[:capturable]
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

  def update_pieces(from, to, piece)
    pieces.delete(from)
    pieces[to] = piece
  end
end
