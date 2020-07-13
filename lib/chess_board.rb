# frozen_string_literal: true

require_relative 'chess_config'
require_relative 'board'
require_relative 'chess_pieces'

# Board initialized with chess pieces
class ChessBoard < Board
  attr_reader :pieces, :graveyard
  def initialize(pieces)
    super()
    # Places each pieceo on the board
    pieces.each do |location, piece|
      set(location, piece)
    end
  end
end
