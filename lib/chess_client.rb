# frozen_string_literal: true

require 'tty-cursor'
require 'tty-prompt'
require 'tty-spinner'
require 'yaml'
require_relative 'chess'
require_relative 'chess_config'

# Responsible for prompting the user for input
class ChessClient
  MENU_SELECTIONS = [{ name: 'Move to space', value: :destination },
                     { name: 'Move piece', value: :piece },
                     { name: 'Undo last move', value: :undo },
                     { name: 'Save the game', value: :save },
                     { name: 'Switch player', value: :player },
                     { name: 'Exit', value: :exit }].freeze

  MOVE_SIGNATURE = proc do |move|
    responding_piece = move[:responding_piece]
    " by #{responding_piece} #{responding_piece.position}"
  end

  PROMPT_OPTIONS = { per_page: 6, filter: true, cycle: true }.freeze

  PIECE_ICONS = CConf::PIECE_SYMBOLS.reject { |key| key == :default }
                                    .values.flat_map(&:values)

  attr_accessor :game, :prompt, :cursor, :filtered_moves, :players
  def initialize
    self.prompt = TTY::Prompt.new(help_color: :red, interrupt: :exit)
    self.cursor = TTY::Cursor
    self.filtered_moves = {}
    self.players = %i[white black].cycle
  end

  # connect to run main game loop
  def connect
    load_game
    generate_filtered_moves
    loop do
      player = players.next
      draw(player)
      selection = prompt.select('What would you like to do?', MENU_SELECTIONS, **PROMPT_OPTIONS)
      case selection
      when :piece
        piece = prompt.select('Pick a piece to move', piece_choices(player).shuffle, **PROMPT_OPTIONS)
        move, position = prompt.select('Pick a move', move_choices(piece).shuffle, **PROMPT_OPTIONS)
        game.move(move, position)
        generate_filtered_moves
      when :destination
        move, position = prompt.select('Make a move', moves_by_destination(player).shuffle, **PROMPT_OPTIONS)
        # IMPROVEMENT: clean up code smell
        if move.is_a? Array
          move, position = prompt.select('Make a move', destination_move_choices(move, position).shuffle, **PROMPT_OPTIONS)
        end
        game.move(move, position)
        generate_filtered_moves
      when :undo
        self.game = game.undo
        generate_filtered_moves
      when :save
        save_game
        players.next
      when :exit
        exit
      end
    end
  end

  def self.deserialize_game_state(game_state)
    YAML.load(game_state)
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
    filtered_moves[player].map do |position, moves|
      if moves.size == 1
        move_selection(moves.first, position, &MOVE_SIGNATURE)
      else
        move_types = moves.map do |move|
          "#{move[:responding_piece]} #{move[:responding_piece].position}#{if move[:type] != :free
                                                                             ' ' + move[:type].to_s
                                                                           end}"
        end
        { name: "#{position} by #{move_types.join(', ')}", value: [moves, position] }
      end
    end
  end

  # given a player, all legal moves that the player could make are
  # checked. Whenever a move would put the player in check it is
  # filtered out of the available options
  def check_filtered_moves(player, spinner)
    game.destinations_move_select[player].map do |position, moves|
      moves = moves.reject do |move|
        spinner.spin
        phantom_game = Chess.load_game(game.moves)
        phantom_game.move(move, position)
        phantom_game.check?(player) || (castle_check(move, player) if move[:type] == :castle)
      end
      [position, moves] unless moves.empty?
    end.compact.to_h
  end

  # checks if the king's position or the positions the king passes through
  # while performing a castle will put it in check
  def castle_check(move, player)
    king = move[:responding_piece]
    rook = move[:piece]
    columns = rook.coordinates.column - king.coordinates.column
    # generates the offsets between the rook and the king
    [columns + 2, 0].min.upto([columns - 2, 0].max).any? do |column_offset|
      offset = [column_offset, 0]
      phantom_move = { type: :free, responding_piece: king, level: 0 }
      phantom_king_position = king.offset_position(offset)
      phantom_game = Chess.load_game(game.moves)
      phantom_game.move(phantom_move, phantom_king_position)
      phantom_game.check?(player)
    end
  end

  def destination_move_choices(moves, position)
    moves.map do |move|
      move_selection(move, position, &MOVE_SIGNATURE)
    end
  end

  def draw(player)
    print cursor.clear_screen, cursor.move_to
    game.board.draw
    puts "Turn #{game.moves.size / 2 + 1}, Current player: #{player}"
    print_turn_info
  end

  def generate_filtered_moves
    spinner = TTY::Spinner.new(frames: repeat_frames(PIECE_ICONS, 15))
    %i[white black].each do |player|
      filtered_moves[player] = check_filtered_moves(player, spinner)
    end
    spinner.success
  end
  
  def repeat_frames(arr, repeats = 2)
    result = arr
    (repeats - 1).times do
      result = result.zip(arr)
    end
    result.shuffle.flatten
  end


  def print_turn_info
    %i[white black].each do |player|
      if filtered_moves[player].empty?
        if game.check? player
          puts "#{player.to_s.upcase} IN CHECKMATE"
          puts "#{CConf.opponent(player).to_s.upcase} WINS"
        else
          puts 'STALEMATE'
        end
        exit
      elsif game.check? player
        puts "#{player.to_s.upcase} IN CHECK"
      end
    end
    puts
  end

  def save_game
    default_save_name = DateTime.now.strftime('%Y%m%d%_H%M%S')
    file_name = prompt.ask('Name your save:', default: default_save_name, **PROMPT_OPTIONS)
                      .gsub(/ /, '_') + '.chsav'
    Dir.mkdir CConf::SAVE_DIR unless Dir.exist? CConf::SAVE_DIR
    File.open(File.join(CConf::SAVE_DIR, file_name), 'w') do |file|
      file.puts serialized_game_state
    end
    puts "Game saved to #{file_name}"
    file_name
  end

  def load_save
    Dir.mkdir CConf::SAVE_DIR unless Dir.exist? CConf::SAVE_DIR
    return load_game if Dir.empty? CConf::SAVE_DIR

    save_file = prompt.select('Choose a save file', Dir["#{CConf::SAVE_DIR}/*"], **PROMPT_OPTIONS)
    game_state_set(save_file)
  end

  def game_state_set(save_file)
    game_state = self.class.deserialize_game_state(File.open(save_file, 'r'))
    # players will go through one iteration before any moves are performed
    # so that active player will match the save's player
    players.next if game_state[:active] == active_player
    self.game = Chess.load_game(Marshal.load(game_state[:moves]))
  end

  def load_game
    print cursor.clear_screen, cursor.move_to
    game_type = prompt.select('Pick an option', ['New game', 'Load game', 'Exit'], **PROMPT_OPTIONS)
    self.game = case game_type
                when 'New game'
                  Chess.new
                when 'Load game'
                  load_save
                when 'Exit'
                  exit
                end
  end

  def serialized_game_state
    YAML.dump({ moves: game.serialize_moves, active: active_player })
  end

  def active_player
    players.next
    players.next
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
