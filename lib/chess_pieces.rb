# frozen_string_literal: true

require 'set'
require_relative 'piece'
require_relative 'move_validator'
require_relative 'offset_generator'

# All of the different types of chess pieces
module Pieces
  DIAGONAL_DIRECTIONS = %w[u d].product(%w[r l]).map(&:join)
  CARDINAL_DIRECTIONS = %w[u d l r].freeze

  # The bishop can move any number of spaces diagonally.
  class Bishop < Piece
    def all_moves(&piece_getter)
      # iterates through all four diagonal positions
      paths = proc { |direction| diagonal_paths(direction) }
      validated_moves(DIAGONAL_DIRECTIONS, piece_getter, &paths)
    end
  end

  # A player loses when the king is put in check mate. The king can move in
  # any direction in one space
  class King < Piece
    def all_moves(&piece_getter)
      paths = [-1, 0, 1].repeated_permutation(2)
                        .to_set.delete([0, 0]).map { |move| [move] }
      validated_moves(paths, piece_getter).merge castle(&piece_getter)
    end

    def castle(&piece_getter)
      rooks = { white: %w[a1 h1], black: %w[a8 h8] }
      castle_validator = MoveValidator.new(self, :Castle, &piece_getter)
      castle_validator.validate(rooks[player])
    end
  end
  # Knight moves in an 'L' shape
  class Knight < Piece
    def all_moves(&piece_getter)
      paths = ([-2, 2].product([-1, 1]) +
               [-1, 1].product([-2, 2]))
              .map { |move| [move] }
      validated_moves(paths, piece_getter)
    end
  end

  # Pawn usually moves one space at a time, but can move two spaces as its
  # first move. It can take other pieces diagonally.
  class Pawn < Piece
    attr_accessor :en_passant
    PROMOTE_ROW = { white: 7, black: 0 }.freeze

    def all_moves(&piece_getter)
      # Blocked if the other piece is not a friendly unit
      move_validator = MoveValidator.new(self, :PawnMove, &piece_getter)
      move_validator.validate(move_offsets)
                    .merge(
                      valid_capture_moves(&piece_getter),
                      valid_en_passant_moves(&piece_getter)
                    ) { |_, *moves| moves.min { |a, b| a[:level] <=> b[:level] } }
    end

    def promotable?
      PROMOTE_ROW[player] == coordinates.row
    end

    private

    def valid_capture_moves(&piece_getter)
      capture_validator = MoveValidator.new(self, :PawnCapture, &piece_getter)
      capture_move_offset_paths.reduce({}) do |moves, path|
        moves.merge(capture_validator.validate(path))
      end
    end

    def valid_en_passant_moves(&piece_getter)
      return {} unless en_passant

      en_passant_validator = MoveValidator.new(self, :EnPassant, &piece_getter)
      capture_move_offset_paths.reduce({}) do |moves, path|
        moves.merge(en_passant_validator.validate(path))
      end
    end

    def move_offsets
      if moved?
        { white: [[0, 1]],
          black: [[0, -1]] }
      else
        { white: [[0, 1], [0, 2]],
          black: [[0, -1], [0, -2]] }
      end[player]
    end

    def capture_move_offset_paths
      { white: [[[-1, 1]], [[1, 1]]],
        black: [[[-1, -1]], [[1, -1]]] }[player]
    end
  end

  # The queen can move in any direction until she takes a piece or is at the
  # edge of the board
  class Queen < Piece
    def all_moves(&piece_getter)
      # union of all moves in the diagonal and cardinal directions
      [{ directions: CARDINAL_DIRECTIONS,
         paths: proc { |direction| cardinal_paths(direction) } },
       { directions: DIAGONAL_DIRECTIONS,
         paths: proc { |direction| diagonal_paths(direction) } }]
        .reduce({}) do |moves, axis|
        moves.merge(validated_moves(axis[:directions], piece_getter, &axis[:paths]))
      end
    end
  end

  # The rook can move in any direction vertically or horizontally
  class Rook < Piece
    def all_moves(&piece_getter)
      paths = proc { |direction| cardinal_paths(direction) }
      validated_moves(CARDINAL_DIRECTIONS, piece_getter, &paths)
    end
  end
end
