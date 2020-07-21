# frozen_string_literal: true

require 'set'
require_relative 'piece'
require_relative 'move_validator'
require_relative 'offset_generator'

# All of the different types of chess pieces
module Pieces
  # The bishop can move any number of spaces diagonally.
  class Bishop < Piece
    def valid_moves(&piece_getter)
      # iterates through all four diagonal positions
      directions = %w[u d].product(%w[r l]).map(&:join)
      validated_moves(directions, piece_getter) { |direction| diagonal_moves(direction) }
    end
  end

  # A player loses when the king is put in check mate. The king can move in
  # any direction in one space
  class King < Piece
    def valid_moves(&piece_getter)
      paths = [-1, 0, 1].repeated_permutation(2)
                        .to_set.delete([0, 0]).map { |move| [move] }
      validated_moves(paths, piece_getter)
    end
  end

  # Knight moves in an 'L' shape
  class Knight < Piece
    def valid_moves(&piece_getter)
      paths = ([-2, 2].product([-1, 1]) +
               [-1, 1].product([-2, 2]))
              .map { |move| [move] }
      validated_moves(paths, piece_getter)
    end
  end

  # Pawn usually moves one space at a time, but can move two spaces as its
  # first move. It can take other pieces diagonally.
  class Pawn < Piece
    def valid_moves(&piece_getter)
      move_offsets = { white: [[0, 1], [0, 2]],
                       black: [[0, -1], [0, -2]] }[player]
      # Blocked if the other piece is not a teammate
      move_validator = MoveValidator.new(:AnyPiece, :INTERRUPT)
      move_validator.validate(self, move_offsets, &piece_getter) +
        attack_moves(&piece_getter)
    end

    private

    def attack_moves(&piece_getter)
      move_offsets = { white: [[-1, 1], [1, 1]],
                       black: [[-1, -1], [1, -1]] }[player]
      move_validator = MoveValidator.new(:NonEnemy, :CONTINUE)
      move_validator.validate(self, move_offsets, &piece_getter)
    end
  end

  # The queen can move in any direction until she takes a piece or is at the
  # edge of the board
  class Queen < Piece
  end

  # The rook can move in any direction vertically or horizontally
  class Rook < Piece
    def valid_moves(&piece_getter)
      # iterates through all four diagonal positions
      directions = %w[u d l r]
      validated_moves(directions, piece_getter) { |direction| cardinal_moves(direction) }
    end
  end
end
