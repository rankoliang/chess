# frozen_string_literal: true

# Contains information on the board state
class Board < Array
  def initialize
    replace(Array.new(8) { Array.new(8) })
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

