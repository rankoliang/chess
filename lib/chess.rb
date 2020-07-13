# frozen_string_literal: true

require_relative 'chess_board'
require_relative 'chess_pieces'

# Handles high level game objects
class Chess
  attr_reader :board, :pieces, :players
  def initialize
    self.pieces = ChessConfig.nested_hash_expand(ChessConfig::DEFAULT_LOCATIONS)
                             .map do |player, piece, position|
      [position, self.class.generate_piece(player, piece, position)]
    end.to_h
    self.board = ChessBoard.new(pieces)
  end

  def move(from, to)
    piece = board.at(from)
    return false unless piece

    piece.move(to, board)

    update_pieces(from, to, piece)
  end

  def self.generate_piece(player, piece, position)
    Pieces.const_get(piece).new(position: position, player: player)
  end

  private

  attr_writer :pieces, :board

  def update_pieces(from, to, piece)
    pieces.delete(from)
    pieces[to] = piece
  end
end
