# frozen_string_literal: true

require_relative 'board'

# validates moves for a piece
class MoveValidator
  attr_reader :blocking_strategy, :rescue_strategy, :position_strategy

  def initialize(blocking_strategy = :Standard, rescue_strategy = :INTERRUPT, position_strategy = :Standard)
    self.blocking_strategy = BlockingStrategy.const_get(blocking_strategy).new
    self.rescue_strategy = RescueStrategy.const_get(rescue_strategy)
    self.position_strategy = PositionStrategy.const_get(position_strategy)
  end

  def validate(piece, moves, &piece_get)
    catch :validated do
      moves.each_with_object({}) do |move, validated|
        future_position, contesting_piece =
          contesting(move, validated, piece, &piece_get)
        if blocking_strategy.blocked(piece, contesting_piece)
          rescue_strategy.call(validated)
        elsif future_position
          validated[future_position] = :test_value
        end
      end
    end
  end

  private

  attr_writer :blocking_strategy, :rescue_strategy, :position_strategy

  # Returns the coordinates at a future move and the piece that is
  # possibly contesting the current piece
  def contesting(move, validated, original_piece)
    future_position = position_strategy.future_position(original_piece, move)
    # original_piece.offset_position(move)
    query_position = position_strategy.query_position(future_position, original_piece)
    contesting_piece = yield(query_position) if block_given?
    [future_position, contesting_piece]
  rescue IndexError
    rescue_strategy.call(validated)
  end
end

# Checks if a piece blocks another piece
module BlockingStrategy
  # Blocked by friendly units and after a capture
  class Standard
    def initialize
      self.capture = false
    end

    def blocked(main, other)
      return true if capture

      if main.enemy? other
        self.capture = true
        false
      else
        main.friendly? other
      end
    end

    private

    attr_accessor :capture
  end

  # Blocked by any piece
  class AnyPiece
    def blocked(_main, other)
      !!other
    end
  end

  # blocked if opposing piece is an enemy
  class Enemy
    def blocked(main, other)
      main.enemy? other
    end
  end

  # blocked if opposing piece not is an enemy
  class NonEnemy
    def blocked(main, other)
      main.non_enemy? other
    end
  end

  # blocked if opposing piece is friendly
  class Friendly
    def blocked(main, other)
      main.friendly? other
    end
  end

  # not blocked by anything
  class NoBlock
    def blocked(_main, _other)
      false
    end
  end

  # Blocked if not an EnPassant pair
  class EnPassant
    def blocked(main, other)
      main.en_passant != other.position
    end
  end
end

module RescueStrategy
  INTERRUPT = proc { |validated| throw :validated, validated }
  CONTINUE = proc { next }
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
