# frozen_string_literal: true

# Stores meta information on the player
class Player
  attr_reader :color, :name
  def initialize(color, name = color.to_s)
    self.color = color
    self.name = name
  end

  def to_s
    name
  end

  private

  attr_writer :color, :name
end
