# frozen_string_literal: true

require_relative 'board'
require_relative 'chess_config'

# Base class that chess pieces inherit from
class Piece
  attr_reader :position, :player
  # position is an array in the format [column_index, row_index]
  def initialize(position: nil, player: nil)
    self.position = position
    self.player = player
  end

  # Outputs the piece's unicode character
  def to_s
    default_symbol = ChessConfig::PIECE_SYMBOLS[:default]
    ChessConfig::PIECE_SYMBOLS[player][self.class.to_s.to_sym] || default_symbol
  rescue NoMethodError
    default_symbol
  end

  def self.from_chess_notation(position:, player: nil)
    new(position: Board.notation_to_coord(position), player: player)
  end

  private

  attr_writer :position, :player
end
