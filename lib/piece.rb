# frozen_string_literal: true

require 'ostruct'
require_relative 'board'
require_relative 'chess_config'

# Base class that chess pieces inherit from
class Piece
  attr_reader :position, :player, :moved
  # position is an array in the format [column_index, row_index]
  def initialize(position: nil, player: nil)
    self.player = player
    self.position = position
    self.moved = false
  end

  # Outputs the piece's unicode character
  def to_s
    default_symbol = CConf::PIECE_SYMBOLS[:default]
    CConf::PIECE_SYMBOLS[player][type] || default_symbol
  rescue NoMethodError
    default_symbol
  end

  # Moves a piece to any space with no restrictions
  def move(new_position)
    yield(new_position, self) if block_given?
    self.position = new_position
    self.moved = true
    nil
  end

  def offset_position(move)
    column_offset, row_offset = move
    Board.chess_notation(
      coordinates.column + column_offset,
      coordinates.row + row_offset
    )
  end

  def enemy
    { white: :black, black: :white }[player]
  end

  def enemy?(other)
    other.player != player
  rescue NoMethodError
    false
  end

  def non_enemy?(other)
    other.player == player
  rescue NoMethodError
    true
  end

  def friendly?(other)
    other.player == player
  rescue NoMethodError
    false
  end

  def valid_moves(&piece_getter)
    # selects all level 0 moves (moves that are either a capture or a free move)
    all_moves(&piece_getter).select do |_, move_info|
      move_info && move_info[:level].zero?
    end
  end

  def type
    self.class.to_s.split('::').last.to_sym
  end

  def coordinates
    column_index, row_index = *Board.notation_to_coord(position)
    OpenStruct.new(column: column_index, row: row_index)
  end

  private

  attr_reader :board
  attr_writer :position, :player, :board, :coordinates, :moved
  alias moved? moved

  # u = up, l = left, d = down, r = right
  def diagonal_paths(direction)
    off_gen = DiagonalOffsetGenerator.new(coordinates, direction)
    off_gen.moves
  end

  # u = up, l = left, d = down, r = right
  def cardinal_paths(direction)
    off_gen = CardinalOffsetGenerator.new(coordinates, direction)
    off_gen.moves
  end

  def validated_moves(paths, piece_getter)
    paths.map do |path|
      moves = block_given? ? yield(path) : path
      move_validator = MoveValidator.new(self, &piece_getter)
      move_validator.validate(moves)
    end.reduce({}, &:merge)
  end
end
