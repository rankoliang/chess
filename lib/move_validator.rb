# frozen_string_literal: true

require_relative 'board'
require_relative 'move_validator/blocking_strategy'
require_relative 'move_validator/position_strategy'

# validates moves for a piece
class MoveValidator
  STRATEGY_TYPE = Hash.new(:Standard).update(EnPassant: :EnPassant, Castle: :Castle)

  attr_reader :blocking_type, :rescue_strategy, :position_strategy, :blocking_strategy,
              :piece, :piece_get

  def initialize(piece, blocking_type = :Standard, &piece_get)
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
    future_position, query_position = position_strategy.positions(piece, move)
    contesting_piece = piece_get.call(query_position) if piece_get
    [future_position, contesting_piece]
  end
end
