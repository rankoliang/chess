# frozen_string_literal: true

require 'date'
require_relative 'chess_board'
require_relative 'chess_pieces'
require_relative 'player'
require_relative 'chess_config'

# Handles high level game objects
class Chess
  attr_reader :board, :pieces, :players, :kings, :moves
  def initialize
    generate_pieces
    self.kings = pieces.filter_map { |_, piece| piece if piece.class == Pieces::King }
    self.players = %i[white black].map do |player_color|
      Player.new(player_color)
    end
    self.board = ChessBoard.new(pieces)
    self.moves = []
  end

  def move(from, to)
    piece = board.at(from)
    return false unless piece

    piece.move(to) { |new_position| board.move_piece(new_position, piece) }

    update_pieces(from, to, piece)
    moves << [from, to]
  end

  def pieces_by_player(player)
    pieces.filter_map { |_, piece| piece if piece.player == player }
  end

  def king_locations
    kings.map { |king| [king.player, king.position] }.to_h
  end

  def check?(color)
    pieces_by_player(color).map(&:valid_moves).any? do |move|
      move == king_locations[CConf.opponent(color)]
    end
  end

  def show
    board.draw
  end

  def save_game(save_dir = CConf::SAVE_DIR)
    Dir.mkdir save_dir unless Dir.exist? save_dir
    save_file_name = DateTime.now.strftime('%Y%m%d%H%M%S') + '-chess.sav'
    File.open(File.join(save_dir, save_file_name), 'w') do |file|
      file.puts Marshal.dump(moves)
    end
    puts "Game saved to #{save_file_name}"
    save_file_name
  end

  def self.load_game(save_file, save_dir = CConf::SAVE_DIR)
    game = new
    moves = Marshal.load(File.open(File.join(save_dir, save_file), 'r').read)
    moves.each { |from, to| game.move(from, to) }
    game
  end

  private

  attr_writer :pieces, :board, :players, :kings, :moves

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
