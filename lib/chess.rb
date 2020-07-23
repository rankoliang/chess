# frozen_string_literal: true

require_relative 'chess_board'
require_relative 'chess_pieces'
require_relative 'player'
require_relative 'chess_config'

# Handles high level game objects
class Chess
  attr_reader :board, :pieces, :players, :kings
  def initialize
    generate_pieces
    self.kings = pieces.filter_map { |_, piece| piece if piece.class == Pieces::King }
    self.players = %i[white black].map do |player_color|
      Player.new(player_color)
    end
    self.board = ChessBoard.new(pieces)
  end

  def move(from, to)
    piece = board.at(from)
    return false unless piece

    piece.move(to, board)

    update_pieces(from, to, piece)
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

  # def save_game(save_dir = 'saves')
  #   Dir.mkdir save_dir unless Dir.exist? save_dir
  #   # sets own save file name
  #   unless save_file_name
  #     next_file_num = Dir.glob(self.class.save_file_glob).map { |file| File.basename(file, '.save').split('-').last.to_i }.max + 1 || 0
  #     save_file = "slot-#{next_file_num}.save"
  #     self.save_file_name = save_file
  #   end
  #   File.open(File.join(save_dir, save_file_name), 'w') do |file|
  #     file.puts Marshal.dump(self)
  #   end
  #   puts "Game saved to #{save_file_name}"
  # end

  private

  attr_writer :pieces, :board, :players, :kings

  # def self.save_file_glob(save_dir = 'saves')
  #   File.join(save_dir, '*.save')
  # end

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
