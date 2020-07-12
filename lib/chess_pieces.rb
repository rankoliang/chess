# frozen_string_literal: true

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
  end

  # The queen can move in any direction until she takes a piece or is at the
  # edge of the board
  class Queen < Piece
  end

  # The rook can move in any direction vertically or horizontally
  class Rook < Piece
  end
end
