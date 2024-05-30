class Piece
    attr_reader :color
  
    def initialize(color)
      @color = color
    end
  
    def to_s
      " "
    end
  
    def valid_move?(start_pos, end_pos, board)
      # Implement in subclass
      false
    end
  end
  
  class Rook < Piece
    def to_s
      @color == :white ? "\u2656" : "\u265C"
    end
  
    def valid_move?(start_pos, end_pos, board)
      # Rook can move horizontally or vertically any number of squares
      dx, dy = (end_pos[0] - start_pos[0]).abs, (end_pos[1] - start_pos[1]).abs
      (dx.zero? || dy.zero?) && board.clear_path?(start_pos, end_pos)
    end
  end
  
  class Knight < Piece
    def to_s
      @color == :white ? "\u2658" : "\u265E"
    end
  
    def valid_move?(start_pos, end_pos, _board)
      # Knight moves in an L-shape: 2 squares in one direction and then 1 square perpendicular
      dx, dy = (end_pos[0] - start_pos[0]).abs, (end_pos[1] - start_pos[1]).abs
      (dx == 2 && dy == 1) || (dx == 1 && dy == 2)
    end
  end
  
  class Bishop < Piece
    def to_s
      @color == :white ? "\u2657" : "\u265D"
    end
  
    def valid_move?(start_pos, end_pos, board)
      # Bishop moves diagonally any number of squares
      (end_pos[0] - start_pos[0]).abs == (end_pos[1] - start_pos[1]).abs && board.clear_path?(start_pos, end_pos)
    end
  end
  
  class Queen < Piece
    def to_s
      @color == :white ? "\u2655" : "\u265B"
    end
  
    def valid_move?(start_pos, end_pos, board)
      # Queen can move horizontally, vertically, or diagonally any number of squares
      dx, dy = (end_pos[0] - start_pos[0]).abs, (end_pos[1] - start_pos[1]).abs
      (dx.zero? || dy.zero? || dx == dy) && board.clear_path?(start_pos, end_pos)
    end
  end
  
  class King < Piece
    def to_s
      @color == :white ? "\u2654" : "\u265A"
    end
  
    def valid_move?(start_pos, end_pos, _board)
      # King can move one square in any direction
      (end_pos[0] - start_pos[0]).abs <= 1 && (end_pos[1] - start_pos[1]).abs <= 1
    end
  end
  
  class Pawn < Piece
    def to_s
      @color == :white ? "\u2659" : "\u265F"
    end
  
    def valid_move?(start_pos, end_pos, board)
      dx, dy = end_pos[0] - start_pos[0], (end_pos[1] - start_pos[1]).abs
      if @color == :white
        return false unless dx == -1 || (dx == -2 && start_pos[0] == 6)
        return false unless dy.zero? && board.clear_path?(start_pos, end_pos) || dy == 1 && !board.grid[end_pos[0]][end_pos[1]].nil? && board.grid[end_pos[0]][end_pos[1]].color != @color
      else
        return false unless dx == 1 || (dx == 2 && start_pos[0] == 1)
        return false unless dy.zero? && board.clear_path?(start_pos, end_pos) || dy == 1 && !board.grid[end_pos[0]][end_pos[1]].nil? && board.grid[end_pos[0]][end_pos[1]].color != @color
      end
      true
    end
  end


