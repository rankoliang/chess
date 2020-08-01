# frozen_string_literal: true

require 'tty-cursor'
require 'tty-prompt'
require_relative 'chess'

class ChessClient
  attr_accessor :game, :prompt, :cursor
  def initialize
    self.prompt = TTY::Prompt.new(help_color: :red)
    self.cursor = TTY::Cursor
  end

  def connect
    load_game
    draw
    prompt.select('Pick a piece', piece_choices(:white), per_page: 5, filter: true)
  end

  private

  def piece_choices(color)
    game.pieces_by_player(color).map do |position, piece|
      { name: "#{position} - #{piece.class.to_s.match(/Pieces::(.*)/)[1]}", value: position }
    end
  end

  def draw
    print cursor.clear_screen, cursor.move_to
    game.board.draw
  end

  def save_game
    default_save_name = DateTime.now.strftime('%Y%m%d%H%M%S') + '.chsav'
    p prompt.ask('Name your save:', default: default_save_name).gsub(/ /, '_') + '.chsav'
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
