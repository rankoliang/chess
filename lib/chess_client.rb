# frozen_string_literal: true

require 'tty-cursor'
require 'tty-prompt'
require_relative 'chess'

# Responsible for prompting the user for input
class ChessClient
  attr_accessor :game, :prompt, :cursor
  def initialize
    self.prompt = TTY::Prompt.new(help_color: :red)
    self.cursor = TTY::Cursor
  end

  def connect
    prompt_options = { per_page: 5, filter: true }
    load_game
    draw
    3.times do
      piece = prompt.select('Pick a piece to move', piece_choices(:white), **prompt_options)
      move, position = prompt.select('Pick a move', move_choices(piece), **prompt_options)
      game.move(move, position)
      draw
    end
    # save_game
  end

  private

  def piece_choices(color)
    game.pieces_by_player(color).map do |position, piece|
      { name: "#{position} - #{piece.type}", value: piece } unless game.valid_moves(piece).empty?
    end.compact
  end

  def move_choices(piece)
    game.valid_moves(piece).map do |position, move|
      { name: "#{position} - #{move[:type]} #{move[:piece]} #{move[:piece]&.position}", value: [move, position] }
    end
  end

  def draw
    print cursor.clear_screen, cursor.move_to
    game.board.draw
  end

  def save_game
    default_save_name = DateTime.now.strftime('%Y%m%d%H%M%S')
    file_name = prompt.ask('Name your save:', default: default_save_name).gsub(/ /, '_') + '.chsav'
    game.save_game(file_name)
    # TODO: call the save game method and exit the game
  end

  def load_save
    save_file = prompt.select('Choose a save file', Dir['saves/*'])
    self.game = Chess.load_game(save_file)
  end

  def load_game
    print cursor.clear_screen, cursor.move_to
    game_type = prompt.select('Pick an option', ['New game', 'Load game', 'Exit'])
    self.game = case game_type
                when 'New game'
                  Chess.new
                when 'Load game'
                  load_save
                when 'Exit'
                  exit
                end
  end
end

client = ChessClient.new
client.connect
