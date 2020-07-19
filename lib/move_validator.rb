# frozen_string_literal: true

require_relative 'board'

# validates moves for a piece
class MoveValidator
  attr_reader :blocking_strategy, :rescue_strategy

  def initialize(blocking_strategy = :Standard, rescue_strategy = :INTERRUPT)
    self.blocking_strategy = BlockingStrategy.const_get(blocking_strategy).new
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

  # blocked if opposing piece is an enemy
  class Enemy
    def blocked(main, other)
      main.enemy? other
    rescue NoMethodError
      false
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
end

module RescueStrategy
  INTERRUPT = proc { |validated| throw :validated, validated.to_set }
  CONTINUE = proc { next }
end
