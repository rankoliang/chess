# frozen_string_literal: true

require_relative 'board'

# Base class that chess pieces inherit from
class Piece
  attr_reader :position, :player
  # position is an array in the format [column_index, row_index]
  def initialize(position: nil, player: nil)
    self.position = position
    self.player = player
  end

  def to_s
    '?'
  end

  def self.from_chess_notation(position:, player: nil)
    new(position: Board.notation_to_coord(position), player: player)
  end

  private

  attr_writer :position, :player
end
