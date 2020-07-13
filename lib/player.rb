# frozen_string_literal: true

# Stores meta information on the player
class Player
  attr_reader :color, :name, :pieces
  def initialize(color, name = color.to_s, pieces: {})
    self.color = color
    self.name = name
    self.pieces = pieces
  end

  private

  attr_writer :color, :name, :pieces
end
