# frozen_string_literal: true

# Checks if a piece blocks another piece
module BlockingStrategy
  # Blocked by friendly units and after a capture
  class Standard
    def initialize(&piece_get)
      self.blocking_level = 0
      self.move_type = :free
      # the piece can capture an enemy piece at this block
      self.capturable = true
      # the piece can move to this position freely
      self.movable = true
      self.piece_get = piece_get if block_given?
    end

    def move_info(main, other)
      post_capture_update
      move_info_update(main, other)
      return unless move_type

      { type: move_type, piece: piece, level: blocking_level,
        capturable: capturable, movable: movable, responding_piece: main }
    end

    private

    attr_accessor :capture, :blocking_level, :piece,
                  :move_type, :capturable, :movable,
                  :piece_get

    def post_capture_update
      return if move_type == :free

      self.blocking_level += 1 unless move_type == :blocked
      self.move_type = :free
    end

    def move_info_update(main, other)
      if main.enemy? other
        capture_update other
      elsif main.friendly? other
        block_update other
      end
    end

    def capture_update(other)
      self.piece = other
      self.move_type = :capture
    end

    def block_update(other)
      self.move_type = :blocked
      self.blocking_level += 1
      self.piece = other
    end
  end

  # Blocked by any piece
  class PawnMove < Standard
    def initialize
      super
      self.capturable = false
    end

    private

    def move_info_update(_main, other)
      block_update(other) if !!other
    end
  end

  # captures if opposing piece is an enemy
  class PawnCapture < Standard
    def initialize
      super
      self.movable = false
    end

    private

    def move_info_update(main, other)
      if main.enemy? other
        capture_update(other)
      else
        block_update(other)
      end
    end
  end

  # Blocked if not an EnPassant pair
  class EnPassant < Standard
    def initialize
      super
      self.movable = false
    end

    private

    def move_info_update(main, other)
      if main.en_passant == other&.position
        self.piece = other
        self.move_type = :en_passant
      else
        block_update(other)
      end
    end
  end

  class Castle < Standard
    def initialize
      super
      self.capturable = false
    end

    private

    def post_capture_update(*_args, **_kwargs); end

    def move_info_update(main, other)
      if other.class == Pieces::Rook && !main.moved? && !other.moved? && check_inbetween(main, other)
        self.move_type = :castle
        self.piece = other
      else
        self.move_type = nil
      end
    end

    def check_inbetween(main, rook)
      return unless rook

      columns = rook.coordinates.column - main.coordinates.column
      # generates the offsets between the rook and the king
      # and checks the board for any pieces inbetween them
      [columns + 1, 1].min.upto([columns - 1, -1].max).map do |column_offset|
        [column_offset, 0]
      end.none? { |offset| piece_get.call(main.offset_position(offset)) }
    end
  end
end
