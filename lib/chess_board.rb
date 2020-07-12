# frozen_string_literal: true

require_relative 'chess_config'
require_relative 'board'
require_relative 'chess_pieces'

# Board initialized with chess pieces
class ChessBoard < Board
  attr_reader :pieces, :graveyard
  def initialize
    super
    self.pieces = {}
    ChessConfig.nested_hash_expand(ChessConfig::DEFAULT_LOCATIONS)
               .each do |player, piece, position|
      pieces[position] = generate_piece(player, piece, position)
    end
    @graveyard = {}
  end

  def set(position, value)
    super
    return unless value

    pieces.delete(value.position)
    pieces[position]
  end

  private

  attr_writer :pieces
  def generate_piece(player, piece, position)
    Pieces.const_get(piece).new(position: position, player: player, board: self)
  end
end
