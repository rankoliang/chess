# frozen_string_literal: true

require_relative 'chess_board'
require_relative 'chess_pieces'
require_relative 'player'

# Handles high level game objects
class Chess
  attr_reader :board, :pieces, :players
  def initialize
    self.pieces = ChessConfig.nested_hash_expand(ChessConfig::DEFAULT_LOCATIONS)
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

    piece.move(to, board)

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
