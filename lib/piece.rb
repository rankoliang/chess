# frozen_string_literal: true

require_relative 'board'

# Base class that chess pieces inherit from
class Piece
  attr_reader :position
  # position is an array in the format [column_index, row_index]
  def initialize(position = nil)
    self.position = position
  end

  def to_s
    '?'
  end

  def self.from_chess_notation(position)
    new(Board.notation_to_coord(position))
  end

  private

  attr_writer :position
end
