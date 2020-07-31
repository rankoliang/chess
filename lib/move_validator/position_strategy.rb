# frozen_string_literal: true

module PositionStrategy
  # the position at the offset
  class Standard
    def self.positions(piece, move)
      Array.new(2) { piece.offset_position(move) }
    end
  end

  # En Passant checks a different position than normal
  class EnPassant
    def self.positions(piece, move)
      future_position = piece.offset_position(move)
      coordinates = Board.notation_to_coord(future_position)
      coordinates[1] -= { black: -1, white: 1 }[piece.player]
      [future_position, Board.chess_notation(*coordinates)]
    end
  end

  # returns the king's final position and the rook's original position
  class Castle < Standard
    def self.positions(king, rook_position)
      king_column, king_row = Board.notation_to_coord(king.position)
      rook_column, = Board.notation_to_coord(rook_position)

      if king_column < rook_column
        king_column += 2
      else
        king_column -= 2
      end

      [Board.chess_notation(king_column, king_row), rook_position]
    end
  end
end
