# frozen_string_literal: true

require_relative 'board'

# validates moves for a piece
class MoveValidator
  attr_reader :blocking_strategy, :rescue_strategy

  def initialize(blocking_strategy = :Friendly, rescue_strategy = :INTERRUPT)
    self.blocking_strategy = BlockingStrategy.const_get(blocking_strategy)
    self.rescue_strategy = RescueStrategy.const_get(rescue_strategy)
  end

  def validate(piece, moves, &piece_get)
    catch :validated do
      moves.each_with_object([]) do |move, validated|
        future_position, contesting_piece = contesting(move, validated, piece, &piece_get)
        if blocking_strategy.blocked(piece, contesting_piece)
          rescue_strategy.call(validated)
        else
          validated << future_position
        end
      end
    end
  end

  private

  attr_writer :blocking_strategy, :rescue_strategy

  # Returns the coordinates at a future move and the piece that is
  # possibly contesting the current piece
  def contesting(move, validated, original_piece)
    future_position = original_piece.offset_position(move)
    contesting_piece = yield(future_position) if block_given?
    [future_position, contesting_piece]
  rescue IndexError
    rescue_strategy.call(validated)
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

  # blocked if opposing piece is friendly
  class Friendly
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
  INTERRUPT = proc { |validated| throw :validated, validated.to_set }
  CONTINUE = proc { next }
end
