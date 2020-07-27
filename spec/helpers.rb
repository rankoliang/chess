# frozen_string_literal: true

# Helper methods for RSpec tests
module Helpers
  # :reek:UtilityFunction
  def move_hash_generate(positions, move_info)
    positions.each_with_object({}) do |move, moves|
      moves[move] = move_info
    end
  end

  def move(type, piece_location, level, capturable: true, movable: true)
    { type: type,
      piece: piece_get.call(piece_location),
      level: level,
      capturable: capturable,
      movable: movable }
  end
end
