# frozen_string_literal: true

require 'ostruct'
require_relative 'board'
require_relative 'chess_config'

# Base class that chess pieces inherit from
class Piece
  attr_reader :position, :player
  # position is an array in the format [column_index, row_index]
  def initialize(position: nil, player: nil)
    self.player = player
    self.position = position
  end

  # Outputs the piece's unicode character
  def to_s
    default_symbol = ChessConfig::PIECE_SYMBOLS[:default]
    ChessConfig::PIECE_SYMBOLS[player][type] || default_symbol
  rescue NoMethodError
    default_symbol
  end

  # Moves a piece to any space with no restrictions
  def move(new_position, board)
    board.move_piece(new_position, self)
    self.position = new_position
  end

  protected

  def opposing_player?(other)
    other.player != player
  rescue NoMethodError
    false
  end

  private

  attr_reader :board
  attr_writer :position, :player, :board, :coordinates

  def type
    self.class.to_s.split('::').last.to_sym
  end

  def coordinates
    column_index, row_index = *Board.notation_to_coord(position)
    OpenStruct.new(column: column_index, row: row_index)
  end
end
