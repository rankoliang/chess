# frozen_string_literal: true

require_relative 'board'
require_relative 'chess_config'

# Base class that chess pieces inherit from
class Piece
  attr_reader :position, :player
  # position is an array in the format [column_index, row_index]
  def initialize(position: nil, player: nil, board: nil)
    self.position = position
    self.player = player
    self.board = board
  end

  # Outputs the piece's unicode character
  def to_s
    default_symbol = ChessConfig::PIECE_SYMBOLS[:default]
    ChessConfig::PIECE_SYMBOLS[player][self.class.to_s.to_sym] || default_symbol
  rescue NoMethodError
    default_symbol
  end

  # Moves a piece to any space with no restrictions
  def move(new_position)
    board.move_piece(new_position, self)
    self.position = new_position
  end

  private

  attr_reader :board
  attr_writer :position, :player, :board
end
