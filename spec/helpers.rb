# frozen_string_literal: true

# Helper methods for RSpec tests
module Helpers
  # :reek:UtilityFunction
  def move_hash_generate(positions, move_info)
    positions.each_with_object({}) do |move, moves|
      moves[move] = move_info
    end
  end
end
