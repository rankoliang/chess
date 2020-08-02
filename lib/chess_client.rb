# frozen_string_literal: true

require 'tty-cursor'
require 'tty-prompt'
require_relative 'chess'
require_relative 'chess_config'

# Responsible for prompting the user for input
class ChessClient
  MENU_SELECTIONS = [{ name: 'Pick a destination', value: :destination },
                     { name: 'Pick a piece', value: :piece },
                     { name: 'Undo last move', value: :undo },
                     { name: 'Save the game', value: :save },
                     { name: 'Change the player', value: :player },
                     { name: 'Exit', value: :exit }].freeze

  MOVE_SIGNATURE = proc do |move|
    responding_piece = move[:responding_piece]
    " by #{responding_piece} #{responding_piece.position}"
  end

  attr_accessor :game, :prompt, :cursor
  def initialize
    self.prompt = TTY::Prompt.new(help_color: :red)
    self.cursor = TTY::Cursor
  end

  def connect
    prompt_options = { per_page: 5, filter: true }
    load_game
    player = :white
    loop do
      draw(player)
      selection = prompt.select('What would you like to do?', MENU_SELECTIONS, **prompt_options)
      case selection
      when :piece
        piece = prompt.select('Pick a piece to move', piece_choices(player), **prompt_options)
        move, position = prompt.select('Pick a move', move_choices(piece), **prompt_options)
        game.move(move, position)
      when :destination
        move, position = prompt.select('Make a move', moves_by_destination(player), **prompt_options)
        # IMPROVEMENT: clean up code smell
        if move.is_a? Array
          move, position = prompt.select('Pick a move', destination_move_choices(move, position), **prompt_options)
        end
        game.move(move, position)
      when :undo
        self.game = game.undo
      when :player
        player = prompt.select('Choose a player', %i[white black])
      when :save
        save_game
      when :exit
        exit
      end
    end
  end

  private

  def piece_choices(color)
    game.pieces_by_player(color).map do |position, piece|
      { name: "#{position} - #{piece.type}", value: piece } unless game.valid_moves(piece).empty?
    end.compact
  end

  def move_choices(piece)
    game.valid_moves(piece).map do |position, move|
      move_selection(move, position)
    end
  end

  def moves_by_destination(player)
    # p check_filtered_moves(player)
    check_filtered_moves(player).map do |position, moves|
      if moves.size == 1
        move_selection(moves.first, position, &MOVE_SIGNATURE)
      else
        move_types = moves.map do |move|
          "#{move[:responding_piece]} #{move[:responding_piece].position}#{' ' + move[:type].to_s if move[:type] != :free}"
        end
        { name: "#{position} by #{move_types.join(', ')}", value: [moves, position] }
      end
    end
  end

  def check_filtered_moves(player)
    game.destinations_move_select do |move|
      move[:level] == 0 && move[:responding_piece].player == player
    end.map do |position, moves|
      moves = moves.reject do |move|
        dummy_game = Chess.replay_moves(game.moves) 
        dummy_game.move(move, position)
        dummy_game.check?(player)
      end
      [position, moves] if !moves.empty?
    end.compact.to_h
  end

  def destination_move_choices(moves, position)
    moves.map do |move|
      move_selection(move, position, &MOVE_SIGNATURE)
    end
  end

  def draw(player)
    print cursor.clear_screen, cursor.move_to
    game.board.draw
    puts "Turn #{game.moves.size}, Current player: #{player.upcase}"
    [:white, :black].each do |player|
      filtered_moves = check_filtered_moves(player)
      if filtered_moves.empty?
        puts "#{player.to_s.upcase} IN CHECKMATE"
      elsif game.check? player
        puts "#{player.to_s.upcase} IN CHECK"
      end
    end
    puts
  end

  def save_game
    default_save_name = DateTime.now.strftime('%Y%m%d%_H%M%S')
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

  # returns a single selection for a given move
  def move_selection(move, position)
    move_type = move[:type]
    piece_signature = block_given? ? yield(move) : ''
    if move_type == :free
      { name: position.to_s + piece_signature, value: [move, position] }
    else
      { name: "#{position} #{move_type} #{move[:piece]} #{move[:piece]&.position}" + piece_signature,
        value: [move, position] }
    end
  end
end

client = ChessClient.new
client.connect
