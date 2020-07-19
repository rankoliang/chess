# frozen_string_literal: true

# dynamically generates offsets from a starting coordinate to a board's
# boundaries
class OffsetGenerator
  def initialize(coordinates, direction)
    pre_initialize(coordinates, direction)
    raise NotImplementedError, "#{self.class}.directions is not implemented" unless directions

    self.coordinates = coordinates
    self.steps = step_directions.map do |axis, step_map|
      directional_step = step_map[directions[axis]] || 0
      [axis, directional_step]
    end.to_h
    self.offset = 1
  end

  def moves
    generate_moves.to_h
  end

  private

  attr_accessor :coordinates, :steps, :offset

  def step_directions
    raise NotImplementedError
  end

  def direction
    raise NotImplementedError
  end

  def generate_moves
    Enumerator.new do |yielder|
      # TODO: can be improved by calculating the number of iterations
      # instead of checking every iteration (wishlist)
      while within_boundaries
        yielder << [steps[:hor] * offset, steps[:vert] * offset]
        self.offset += 1
      end
    end
  end

  def offset_coordinates
    column, row = coordinates.to_h.values_at(:column, :row)
    [column + steps[:hor] * offset, row + steps[:vert] * offset]
  end

  def within_boundaries
    offset_coordinates[0].between?(0, CConf::BOARD_WIDTH - 1) &&
      offset_coordinates[1].between?(0, CConf::BOARD_HEIGHT - 1)
  end
end

# Generates diagonal offsets
class DiagonalOffsetGenerator < OffsetGenerator
  def pre_initialize(_coordinates, direction)
    # Hash of directions (u, l, r, d)
    self.directions = Hash[%i[vert hor].zip(direction.split('').map(&:to_sym))]
  end

  private

  attr_accessor :directions

  def step_directions
    @step_directions ||= { vert: { u: 1, d: -1 }, hor: { r: 1, l: -1 } }
  end
end
