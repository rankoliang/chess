# frozen_string_literal: true

require_relative 'chess_config'
require 'paint'
require 'forwardable'

# Contains information on the board state
class Board
  attr_reader :board_array

  extend Forwardable
  include Enumerable

  def initialize
    # Initializes the board to be an array
    self.board_array = Array.new(CConf::BOARD_HEIGHT) do
      Array.new(CConf::BOARD_WIDTH)
    end
    reset_background
  end

  def to_s
    # Draws from the bottom to up
    board_display = reverse.zip(board_fg.reverse, board_bg.reverse).map.with_index do |row, row_index|
      self.class.row_to_s(row_index, row)
    end.join("\n")

    # column_labels = ('a'..'z').to_a[0...CConf::BOARD_WIDTH]
    column_header = "   #{CConf::COLUMN_LABELS.join('  ')}"
    "#{column_header}\n#{board_display}"
  end

  def draw
    puts to_s
  end

  def self.row_to_s(row_index, row)
    pieces, foreground, background = row
    row_of_pieces = pieces.zip(foreground, background).map do |piece, fg_color, bg_color|
      piece ||= ' '
      Paint[" #{piece} ", fg_color, bg_color]
    end.join

    "#{CConf::BOARD_HEIGHT - row_index} #{row_of_pieces}"
  end

  def_delegators :board_array, :[], :reverse, :each, :to_ary, :each_index, :size

  def dimensions
    height = board_array.size
    width = self[0].size
    [width, height]
  end

  # Highlights each element of the row to alternate colors
  # :reek:DuplicateMethodCall
  def self.row_background(row, row_index)
    row.each_index.map do |column_index|
      if (row_index + column_index).even?
        CConf::BACKGROUND_DARK[Paint.mode]
      else
        CConf::BACKGROUND_LIGHT[Paint.mode]
      end
    end
  end

  # returns the chess piece at a certain position matching the format /[a..z]\d/
  def at(position)
    column_index, row_index = self.class.notation_to_coord(position)

    self[row_index][column_index]
  end

  def set(position, value)
    column_index, row_index = self.class.notation_to_coord(position)

    self[row_index][column_index] = value
  end

  # method moves a piece to a new space. The piece position is not updated
  def move_piece(to, piece)
    from = piece.position
    yield at(to) if block_given?
    set(to, piece)
    set(from, nil) if from
  end

  class << self
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
      unless column_index.between?(0, CConf::BOARD_WIDTH) &&
             row_index.between?(0, CConf::BOARD_HEIGHT)
        raise IndexError, "[#{column_index}, #{row_index}] is out of bounds!"
      end
    end
  end

  private

  attr_writer :board_array
  attr_accessor :board_bg, :board_fg

  # Overrides the default background colors
  def hl_space(color, column_index, row_index)
    board_bg[row_index][column_index] = color if CConf::COLOR_CODES.key?(color)
  end

  # colors the background of the chess board to be alternating
  # :reek:DuplicateMethodCall
  def reset_background
    self.board_bg = board_array.map.with_index do |row, row_index|
      self.class.row_background(row, row_index)
    end
    self.board_fg = board_array.map { |row| row.map { CConf::PIECE_COLOR[Paint.mode] } }
  end
end
