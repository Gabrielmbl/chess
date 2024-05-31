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

    def possible_moves(start_pos, board)
      # Implement in subclass
      []
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

    def possible_moves(start_pos, board)
      moves = []
      (0..7).each do |i|
        moves << [start_pos[0], i]
        moves << [i, start_pos[1]]
      end
      moves.select { |end_pos| valid_move?(start_pos, end_pos, board) }
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

    def possible_moves(start_pos, board)
      moves = []
      move_offsets = [[-2, -1], [-1, -2], [1, -2], [2, -1], [2, 1], [1, 2], [-1, 2], [-2, 1]]
      move_offsets.each do |dx, dy|
        end_pos = [start_pos[0] + dx, start_pos[1] + dy]
        moves << end_pos if (0..7).include?(end_pos[0]) && (0..7).include?(end_pos[1]) && valid_move?(start_pos, end_pos, board)
      end
      moves
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

    def possible_moves(start_pos, board)
      moves = []
      (1..7).each do |i|
        moves << [start_pos[0] + i, start_pos[1] + i]
        moves << [start_pos[0] - i, start_pos[1] - i]
        moves << [start_pos[0] + i, start_pos[1] - i]
        moves << [start_pos[0] - i, start_pos[1] + i]
      end
      moves.select { |end_pos| (0..7).include?(end_pos[0]) && (0..7).include?(end_pos[1]) && valid_move?(start_pos, end_pos, board) }
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

    def possible_moves(start_pos, board)
      moves = []
      (0..7).each do |i|
        moves << [start_pos[0], i]
        moves << [i, start_pos[1]]
        moves << [start_pos[0] + i, start_pos[1] + i]
        moves << [start_pos[0] - i, start_pos[1] - i]
        moves << [start_pos[0] + i, start_pos[1] - i]
        moves << [start_pos[0] - i, start_pos[1] + i]
      end
      moves.select { |end_pos| (0..7).include?(end_pos[0]) && (0..7).include?(end_pos[1]) && valid_move?(start_pos, end_pos, board) }
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

    def possible_moves(start_pos, board)
      moves = []
      move_offsets = [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]]
      move_offsets.each do |dx, dy|
        end_pos = [start_pos[0] + dx, start_pos[1] + dy]
        moves << end_pos if (0..7).include?(end_pos[0]) && (0..7).include?(end_pos[1]) && valid_move?(start_pos, end_pos, board)
      end
      moves
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

    def possible_moves(start_pos, board)
      moves = []
      direction = @color == :white ? -1 : 1
      one_step = [start_pos[0] + direction, start_pos[1]]
      two_step = [start_pos[0] + (2 * direction), start_pos[1]]
      diagonal_left = [start_pos[0] + direction, start_pos[1] - 1]
      diagonal_right = [start_pos[0] + direction, start_pos[1] + 1]
  
      moves << one_step if valid_move?(start_pos, one_step, board)
      moves << two_step if (start_pos[0] == 6 || start_pos[0] == 1) && valid_move?(start_pos, two_step, board)
      moves << diagonal_left if valid_move?(start_pos, diagonal_left, board)
      moves << diagonal_right if valid_move?(start_pos, diagonal_right, board)
  
      moves.select { |end_pos| (0..7).include?(end_pos[0]) && (0..7).include?(end_pos[1]) }
    end
    
  end


