# frozen_string_literal: true

require_relative 'chess_config'
require 'forwardable'

# Contains information on the board state
class Board
  attr_reader :board_array

  extend Forwardable
  include Enumerable

  def initialize
    # Initializes the board to be an array
    self.board_array = Array.new(ChessConfig::BOARD_HEIGHT) do
      Array.new(ChessConfig::BOARD_WIDTH)
    end
    reset_background
  end

  def to_s
    # Draws from the bottom to up
    board_display = reverse.map.with_index do |row, row_index|
      row_to_s(row_index, row)
    end.join("\n")

    column_labels = ('a'..'z').to_a[0...ChessConfig::BOARD_WIDTH]
    column_header = "   #{column_labels.join('  ')}"
    "#{column_header}\n#{board_display}"
  end

  def draw
    puts to_s
  end

  def row_to_s(row_index, row)
    row_of_pieces = row.map.with_index do |piece, column_index|
      Board.str_w_bg(piece || ' ', board_bg[row_index][column_index])
    end.join

    "#{ChessConfig::BOARD_HEIGHT - row_index} #{row_of_pieces}"
  end

  def_delegators :board_array, :[], :reverse, :each, :to_ary, :each_index

  def size
    height = board_array.size
    width = self[0].size
    [width, height]
  end

  # Highlights each element of the row to alternate colors
  def self.row_background(row, row_index)
    row.each_index.map do |column_index|
      (row_index + column_index).even? ? :black : :blue
    end
  end

  # returns the chess piece at a certain position matching the format /[a..z]\d/
  def at(position)
    column_index, row_index = self.class.notation_to_coord(position)
    return unless column_index && row_index

    self[row_index][column_index]
  end

  def set(position, value)
    column_index, row_index = self.class.notation_to_coord(position)
    return unless column_index && row_index

    self[row_index][column_index] = value
  end

  # method moves a piece to a new space. The piece position is not updated
  def move_piece(to, piece)
    from = piece.position
    set(from, nil) if from
    yield at(to) if block_given?
    set(to, piece)
  end

  class << self
    def str_w_bg(string, bg_color)
      color_code = ChessConfig::COLOR_CODES[bg_color]
      "\e[#{color_code}m #{string} \e[0m"
    end

    def chess_notation(column_index, row_index)
      check_boundaries(column_index, row_index)

      column = (column_index + 'a'.ord).chr
      "#{column}#{row_index + 1}"
    end

    def notation_to_coord(position)
      column_index = position[0].downcase.ord - 'a'.ord
      row_index = position[1].to_i - 1
      check_boundaries(column_index, row_index)

      [column_index, row_index]
    end

    private

    def check_boundaries(column_index, row_index)
      if column_index >= ChessConfig::BOARD_WIDTH ||
         row_index >= ChessConfig::BOARD_HEIGHT
        raise IndexError, 'Out of bounds!'
      end
    end
  end

  private

  attr_writer :board_array
  attr_accessor :board_bg

  # Overrides the default background colors
  def hl_space(color, column_index, row_index)
    board_bg[row_index][column_index] = color if ChessConfig::COLOR_CODES.key?(color)
  end

  # colors the background of the chess board to be alternating
  def reset_background
    self.board_bg = board_array.map.with_index do |row, row_index|
      self.class.row_background(row, row_index)
    end
  end
end
