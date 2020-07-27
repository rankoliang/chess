# frozen_string_literal: true

require_relative 'board'

# validates moves for a piece
class MoveValidator
  attr_reader :blocking_type, :rescue_strategy, :position_strategy, :blocking_strategy

  def initialize(blocking_type = :Standard, position_strategy = :Standard)
    self.position_strategy = PositionStrategy.const_get(position_strategy)
    self.blocking_type = blocking_type
  end

  def validate(piece, moves, &piece_get)
    self.blocking_strategy = BlockingStrategy.const_get(blocking_type).new
    catch :validated do
      moves.each_with_object({}) do |move, validated|
        validated_update(move, piece, validated, &piece_get)
      rescue IndexError
        next
      end
    end.compact
  end

  private

  attr_writer :blocking_type, :rescue_strategy, :position_strategy, :blocking_strategy

  def validated_update(move, piece, validated, &piece_get)
    future_position, contesting_piece = contesting(move, piece, &piece_get)
    return unless future_position

    move_info = blocking_strategy.move_info(piece, contesting_piece)
    validated[future_position] = move_info
  end

  # Returns the coordinates at a future move and the piece that is
  # possibly contesting the current piece
  def contesting(move, original_piece)
    future_position = position_strategy.future_position(original_piece, move)
    # original_piece.offset_position(move)
    query_position = position_strategy.query_position(future_position, original_piece)
    contesting_piece = yield(query_position) if block_given?
    [future_position, contesting_piece]
  end
end

# Checks if a piece blocks another piece
module BlockingStrategy
  # Blocked by friendly units and after a capture
  class Standard
    def initialize
      self.blocking_level = 0
      self.move_type = :free
      # the piece can capture an enemy piece at this block
      self.capturable = true
      # the piece can move to this position freely
      self.movable = true
    end

    def move_info(main, other)
      post_capture_update
      move_info_update(main, other)
      return unless move_type

      { type: move_type, piece: piece, level: blocking_level,
        capturable: capturable, movable: movable }
    end

    private

    attr_accessor :capture, :blocking_level, :piece, :move_type, :capturable, :movable

    def post_capture_update
      return if move_type == :free

      self.blocking_level += 1 unless move_type == :blocked
      self.move_type = :free
    end

    def move_info_update(main, other)
      if main.enemy? other
        capture_update other
      elsif main.friendly? other
        block_update other
      end
    end

    def capture_update(other)
      self.piece = other
      self.move_type = :capture
    end

    def block_update(other)
      self.move_type = :blocked
      self.blocking_level += 1
      self.piece = other
    end
  end

  # Blocked by any piece
  class PawnMove < Standard
    def initialize
      super
      self.capturable = false
    end

    private

    def move_info_update(_main, other)
      block_update(other) if !!other
    end
  end

  # captures if opposing piece is an enemy
  class PawnCapture < Standard
    def initialize
      super
      self.movable = false
    end

    private

    def move_info_update(main, other)
      if main.enemy? other
        capture_update(other)
      else
        self.move_type = nil
      end
    end
  end

  # Blocked if not an EnPassant pair
  class EnPassant < Standard
    def initialize
      super
      self.movable = false
    end

    private

    def move_info_update(main, other)
      if main.en_passant == other.position
        self.piece = other
        self.move_type = :en_passant
      else
        self.move_type = nil
      end
    end
  end
end

module PositionStrategy
  # the position at the offset
  class Standard
    def self.future_position(original_piece, move)
      original_piece.offset_position(move)
    end

    def self.query_position(future_position, _original_piece)
      future_position
    end
  end

  # En Passant checks a different position than normal
  class EnPassant
    def self.future_position(original_piece, _move)
      coordinates = Board.notation_to_coord original_piece.en_passant
      # increment the row
      coordinates[1] = coordinates[1] + { black: -1, white: 1 }[original_piece.player]
      Board.chess_notation(*coordinates)
    end

    def self.query_position(_future_position, original_piece)
      original_piece.en_passant
    end
  end
end
