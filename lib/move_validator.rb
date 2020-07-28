# frozen_string_literal: true

require_relative 'board'

# validates moves for a piece
class MoveValidator
  STRATEGY_TYPE = Hash.new(:Standard).update(EnPassant: :EnPassant, Castle: :Castle)

  attr_reader :blocking_type, :rescue_strategy, :position_strategy, :blocking_strategy,
              :piece, :piece_get

  def initialize(piece, blocking_type = :Standard,
                 _position_strategy = :Standard, &piece_get)
    self.position_strategy = PositionStrategy.const_get(STRATEGY_TYPE[blocking_type])
    self.blocking_type = blocking_type
    self.piece = piece
    self.piece_get = piece_get if block_given?
  end

  def validate(moves)
    self.blocking_strategy = BlockingStrategy.const_get(blocking_type).new
    catch :validated do
      moves.each_with_object({}) do |move, validated|
        validated_update(move, validated, &piece_get)
      rescue IndexError
        next
      end
    end.compact
  end

  private

  attr_writer :blocking_type, :rescue_strategy, :position_strategy, :blocking_strategy,
              :piece, :piece_get

  def validated_update(move, validated)
    future_position, contesting_piece = contesting(move)
    return unless future_position

    move_info = blocking_strategy.move_info(piece, contesting_piece)
    validated[future_position] = move_info
  end

  # Returns the coordinates at a future move and the piece that is
  # possibly contesting the current piece
  def contesting(move)
    future_position = position_strategy.future_position(piece, move)
    query_position = position_strategy.query_position(future_position, piece)
    contesting_piece = piece_get.call(query_position) if piece_get
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

    attr_accessor :capture, :blocking_level, :piece,
                  :move_type, :capturable, :movable

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
        block_update(other)
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
      if main.en_passant == other&.position
        self.piece = other
        self.move_type = :en_passant
      else
        block_update(other)
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
    def self.future_position(original_piece, move)
      original_piece.offset_position(move)
      # coordinates = original_piece.offset_position(move)
      # coordinates = Board.notation_to_coord coordinates
      # # increment the row
      # # coordinates[1] += { black: -1, white: 1 }[original_piece.player]
      # Board.chess_notation(*coordinates)
    end

    def self.query_position(future_position, original_piece)
      coordinates = Board.notation_to_coord(future_position)
      coordinates[1] -= { black: -1, white: 1 }[original_piece.player]
      Board.chess_notation(*coordinates)
    end
  end
end
