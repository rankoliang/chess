# frozen_string_literal: true

module ChessConfig
  BOARD_WIDTH = 8
  BOARD_HEIGHT = 8
  COLOR_CODES = { black: 40, blue: 44, red: 41, yellow: 42,
                  orange: 43, magenta: 45, green: 46, white: 47 }.freeze
  PIECE_SYMBOLS = { white: { King: "\u265A",
                             Queen: "\u265B",
                             Rook: "\u265C",
                             Bishop: "\u265D",
                             Knight: "\u265E",
                             Pawn: "\u265F" },
                    black: { King: "\u2654",
                             Queen: "\u2655",
                             Rook: "\u2656",
                             Bishop: "\u2657",
                             Knight: "\u2658",
                             Pawn: "\u2659" },
                    default: '?' }.freeze
  COLUMN_LABELS = ('a'..'z').to_a[0...BOARD_WIDTH]
  DEFAULT_LOCATIONS = { white: { Pawn: COLUMN_LABELS.map { |letter| "#{letter}2" },
                                 King: %w[e1],
                                 Queen: %w[d1],
                                 Bishop: %w[c1 f1],
                                 Knight: %w[b1 g1],
                                 Rook: %w[a1 h1] },
                        black: { Pawn: COLUMN_LABELS.map { |letter| "#{letter}7" },
                                 King: %w[e8],
                                 Queen: %w[d8],
                                 Bishop: %w[c8 f8],
                                 Knight: %w[b8 g8],
                                 Rook: %w[a8 h8] } }.freeze
  def self.nested_hash_expand(current_level, keys = [])
    return keys.product([current_level].flatten).map(&:flatten) unless current_level.is_a? Hash

    result = []
    current_level.each do |key, value|
      result.append(*nested_hash_expand(value, [keys + [key]]))
    end
    result
  end
end
