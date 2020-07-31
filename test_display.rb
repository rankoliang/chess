# frozen_string_literal: true

require 'pry'
require_relative 'lib/board'
require_relative 'lib/chess_board'
require_relative 'lib/piece'
require_relative 'lib/chess_pieces'
require_relative 'lib/chess'

chess_game = Chess.new
chess_game.board.draw
chess_game.move('a1', 'a3')
chess_game.board.draw
chess_game.move('a1', 'a3')
chess_game.board.draw
chess_game.save_game
Chess.load_game('20200731195015-chess.sav').board.draw

# # puts board.pieces
# # p ChessBoard.nested_hash_expand(ChessConfig::DEFAULT_LOCATIONS)
# board.pieces.each do |location, piece|
#   p [location, piece.to_s]
# end.size
# board.draw
# board.pieces['a1'].move('a8')
# board.draw
# board.pieces.each do |location, piece|
#   p [location, piece.to_s]
# end.size
# board.draw
# board.pieces.each do |location, piece|
#   p [location, piece.to_s]
# end.size
# # board.draw
