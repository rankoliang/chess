# frozen_string_literal: true

require_relative 'chess_config'

# Contains information on the board state
class Board < Array
  def initialize
    # Initializes the board to be an array
    replace(Array.new(ChessConfig::BOARD_HEIGHT) do
      Array.new(ChessConfig::BOARD_WIDTH)
    end)
  end

  def to_s
    # Draws from the bottom to up
    reverse.map.with_index do |row, row_index|
      row.map.with_index do |piece, column_index|
        background_shade = (row_index + column_index) % 2

        # Display an empty space by default
        piece = ' ' if piece.nil?

        # Draws the piece. Alternates between a blue and black background
        "\e[#{40 + background_shade * 4}m#{piece}\e[0m"
      end.join
    end
  end

  def draw
    puts to_s
  end
end
