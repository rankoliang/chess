# frozen_string_literal: true

require_relative 'chess_board'
require_relative 'chess_pieces'
require_relative 'player'
require_relative 'chess_config'

# Handles high level game objects
class Chess
  attr_reader :board, :pieces, :players
  def initialize
    self.pieces = CConf.nested_hash_expand(CConf::DEFAULT_LOCATIONS)
                       .map do |player, piece, position|
      chess_piece = Pieces.const_get(piece) || Piece
      new_piece = chess_piece.new(position: position, player: player)
      [position, new_piece]
    end.to_h
    self.players = %i[white black].map do |player_color|
      Player.new(player_color)
    end
    self.board = ChessBoard.new(pieces)
  end

  def move(from, to)
    piece = board.at(from)
    return false unless piece

    piece.move(to) { |new_position| board.move_piece(new_position, piece) }

    update_pieces(from, to, piece)
  end

  def pieces_by_player(player)
    pieces.select { |_, piece| piece.player == player }
  end

  def show
    board.draw
  end

  private

  attr_writer :pieces, :board, :players

  def update_pieces(from, to, piece)
    pieces.delete(from)
    pieces[to] = piece
  end
end
