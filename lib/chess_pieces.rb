# frozen_string_literal: true

require 'set'
require_relative 'piece'
require_relative 'move_validator'

# All of the different types of chess pieces
module Pieces
  # TODO: split this function up
  # u = up, l = left, d = down, r = right
  def self.diagonal_moves(coordinates, direction)
    vertical, horizontal = direction.split('').map(&:to_sym)
    vertical_step = { u: 1, d: -1 }[vertical]
    horizontal_step = { r: 1, l: -1 }[horizontal]
    column, row = coordinates.to_h.values
    moves = []
    offset = 0
    while column.between?(0, CConf::BOARD_HEIGHT - 2) && row.between?(0, CConf::BOARD_WIDTH - 2)
      column += 1
      row += 1
      offset += 1
      moves << [horizontal_step * offset, vertical_step * offset]
    end
    moves
  end

  # The bishop can move any number of spaces diagonally.
  class Bishop < Piece
    def valid_moves(&get_occupying_piece)
      # iterates through all four diagonal positions
      %w[u d].product(%w[r l]).map(&:join).map do |direction|
        moves = Pieces.diagonal_moves(coordinates, direction)
        move_validator = MoveValidator.new
        move_validator.validate(self, moves, &get_occupying_piece)
      end.flatten
    end
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
    def valid_moves(&get_occupying_piece)
      moves = [[0, 1], [0, 2]]
      # Blocked if the other piece is not a teammate
      move_validator = MoveValidator.new(
        :Enemy, :INTERRUPT
      )
      move_validator.validate(self, moves, &get_occupying_piece) +
        attack_moves(&get_occupying_piece)
    end

    private

    def attack_moves(&get_occupying_piece)
      moves = [[-1, 1], [1, 1]]
      move_validator = MoveValidator.new(
        :NonEnemy, :CONTINUE
      )
      move_validator.validate(self, moves, &get_occupying_piece)
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
