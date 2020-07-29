# frozen_string_literal: true

module PositionStrategy
  # the position at the offset
  class Standard
    def self.future_position(original_piece, move)
      original_piece.offset_position(move)
    end

    def self.query_position(future_position, _original_piece)
      future_position
    end
  end

  # En Passant checks a different position than normal
  class EnPassant
    def self.future_position(original_piece, move)
      original_piece.offset_position(move)
    end

    def self.query_position(future_position, original_piece)
      coordinates = Board.notation_to_coord(future_position)
      coordinates[1] -= { black: -1, white: 1 }[original_piece.player]
      Board.chess_notation(*coordinates)
    end
  end
end
