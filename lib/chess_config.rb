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
end
