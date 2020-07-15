# frozen_string_literal: true

require 'set'
require_relative 'piece'
# All of the different types of chess pieces
module Pieces
  # The bishop can move any number of spaces diagonally.
  class Bishop < Piece
  end

  # A player loses when the king is put in check mate. The king can move in
  # any direction in one space
  class King < Piece
  end

  # Knight moves in an 'L' shape
  class Knight < Piece
  end

  # Pawn usually moves one space at a time, but can move two spaces as its
  # first move. It can take other pieces diagonally.
  class Pawn < Piece
    # TODO: Refactor to avoid duplication with #attack_moves
    def valid_moves(&piece_at_position)
      valid_moves = []
      1.upto(2).each do |row_offset|
        begin
          pending_move = Board.chess_notation(coordinates.column, coordinates.row + row_offset)
          blocking_piece = piece_at_position.call(pending_move) if block_given?
        rescue IndexError
          next
        end
        valid_moves << pending_move unless opposing_player?(blocking_piece)
      end
      if block_given?
        valid_moves.concat(attack_moves(&piece_at_position))
      else
        valid_moves
      end
    end

    private

    def attack_moves(&piece_at_position)
      valid_moves = []
      [[-1, 1], [1, 1]].each do |column_offset, row_offset|
        begin
          pending_move = Board.chess_notation(coordinates.column + column_offset, coordinates.row + row_offset)
          blocking_piece = piece_at_position.call(pending_move)
        rescue IndexError
          next
        end
        valid_moves << pending_move if opposing_player?(blocking_piece)
      end
      valid_moves
    end
  end

  # The queen can move in any direction until she takes a piece or is at the
  # edge of the board
  class Queen < Piece
  end

  # The rook can move in any direction vertically or horizontally
  class Rook < Piece
  end
end
