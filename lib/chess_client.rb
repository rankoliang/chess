# frozen_string_literal: true

require 'tty-cursor'
require 'tty-prompt'
require_relative 'chess'

class ChessClient
  attr_accessor :game, :prompt, :cursor
  def initialize
    self.prompt = TTY::Prompt.new
    self.cursor = TTY::Cursor
  end

  def connect
    load_game
    draw
  end

  def draw
    print cursor.clear_screen, cursor.move_to
    game.board.draw
  end

  private

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
