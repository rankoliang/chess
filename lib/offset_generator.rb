# frozen_string_literal: true

# dynamically generates offsets from a starting coordinate to a board's
# boundaries
class OffsetGenerator
  def initialize(coordinates, direction, **step_mappings)
    # Hash of directions (u, l, r, d)
    dirs = Hash[
      %i[vert hor].zip(direction.split('').map(&:to_sym))
    ]
    self.coordinates = coordinates
    self.steps = step_mappings.map do |axis, step_map|
      directional_step = step_map[dirs[axis]] || 0
      [axis, directional_step]
    end.to_h
    self.offset = 1
  end

  def moves
    moves = []
    generate { |move| moves << move }
    moves
  end

  private

  attr_accessor :coordinates, :steps, :direction, :offset

  def generate
    while within_boundaries
      yield [steps[:hor] * offset, steps[:vert] * offset]
      self.offset += 1
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
