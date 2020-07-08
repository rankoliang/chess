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

  def size
    height = super
    width = self[0].size
    [width, height]
  end

  def self.chess_notation(column_index, row_index)
    return if column_index >= ChessConfig::BOARD_WIDTH ||
              row_index >= ChessConfig::BOARD_HEIGHT

    column = (column_index + 'a'.ord).chr
    "#{column}#{row_index + 1}"
  end

  # returns the chess piece at a certain position matching the format /[a..z]\d/
  def at(position)
    column = position[0].downcase
    row = position[1]
    column_index = column.ord - 'a'.ord
    row_index = row.to_i - 1

    self[row_index][column_index]
  end

  def to_s
    # Draws from the bottom to up
    board_display = reverse.map.with_index do |row, row_index|
      self.class.row_to_s(row_index, row)
    end.join("\n")

    column_labels = ('a'..'z').to_a[0...ChessConfig::BOARD_WIDTH]
    column_header = "   #{column_labels.join('  ')}"
    "#{column_header}\n#{board_display}"
  end

  def draw
    puts to_s
  end

  def self.row_to_s(row_index, row)
    row_of_pieces = row.map.with_index do |piece, column_index|
      background_shade = (row_index + column_index) % 2

      # Display an empty space by default
      piece = ' ' if piece.nil?

      # Draws the piece. Alternates between a blue and black background
      "\e[#{40 + background_shade * 4}m #{piece} \e[0m"
    end.join

    "#{ChessConfig::BOARD_HEIGHT - row_index} #{row_of_pieces}"
  end
end
