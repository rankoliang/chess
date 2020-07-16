# frozen_string_literal: true

require_relative 'board'

# validates moves for a piece
class MoveValidator
  attr_reader :coordinates, :blocking_strategy, :rescue_strategy

  def initialize(coordinates, blocking_strategy, rescue_strategy)
    self.coordinates = coordinates
    self.blocking_strategy = blocking_strategy
    self.rescue_strategy = rescue_strategy
  end

  def validate(piece, moves)
    moves.each_with_object([]) do |move, validated|
      begin
        validation_position = offset_position(move)
        occupying_piece = yield(validation_position) if block_given?
      rescue IndexError
        rescue_strategy.call(validated)
      end
      next if blocking_strategy.blocked(piece, occupying_piece)

      validated << validation_position
      rescue_strategy.call(validated)
    end
  end

  private

  attr_writer :coordinates, :blocking_strategy, :rescue_strategy

  def offset_position(move)
    column_offset, row_offset = move
    Board.chess_notation(
      coordinates.column + column_offset,
      coordinates.row + row_offset
    )
  end
end

# Checks if a piece blocks another piece
module BlockingStrategy
  # blocked if opposing piece is an enemy
  class Enemy
    def self.blocked(main, other)
      main.player != other.player
    rescue NoMethodError
      false
    end
  end

  # blocked if opposing piece not is an enemy
  class NonEnemy
    def self.blocked(main, other)
      main.player == other.player
    rescue NoMethodError
      true
    end
  end

  # blocked if opposing piece is a teammate
  class Teammate
    def self.blocked(main, other)
      main.player == other.player
    rescue NoMethodError
      false
    end
  end

  # not blocked by anything
  class NoBlock
    def self.blocked(_main, _other)
      false
    end
  end
end

module RescueStrategy
  INTERRUPT = ->(validated) { return validated }
  CONTINUE = proc { next }
end
