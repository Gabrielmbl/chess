require_relative 'pieces'

class ChessBoard
	attr_accessor :grid

  def initialize
    @grid = Array.new(8) { Array.new(8) }
    setup_board
  end

  def setup_board
    # Initialize pieces on the board
		# Set up white pieces
    @grid[0][0] = Rook.new(:white)
    @grid[0][1] = Knight.new(:white)
    @grid[0][2] = Bishop.new(:white)
    @grid[0][3] = Queen.new(:white)
    @grid[0][4] = King.new(:white)
    @grid[0][5] = Bishop.new(:white)
    @grid[0][6] = Knight.new(:white)
    @grid[0][7] = Rook.new(:white)
    (0..7).each { |i| @grid[1][i] = Pawn.new(:white) }

    # Set up black pieces
    @grid[7][0] = Rook.new(:black)
    @grid[7][1] = Knight.new(:black)
    @grid[7][2] = Bishop.new(:black)
    @grid[7][3] = Queen.new(:black)
    @grid[7][4] = King.new(:black)
    @grid[7][5] = Bishop.new(:black)
    @grid[7][6] = Knight.new(:black)
    @grid[7][7] = Rook.new(:black)
    (0..7).each { |i| @grid[6][i] = Pawn.new(:black) }
  end

  def display
    # Display the board
		puts "    a   b   c   d   e   f   g   h  "
    puts "  +---+---+---+---+---+---+---+---+"
    @grid.each_with_index do |row, idx|
      print "#{8 - idx} |"
      row.each do |piece|
        print piece.nil? ? "   |" : " #{piece} |"
      end
      puts " #{8 - idx}"
      puts "  +---+---+---+---+---+---+---+---+"
    end
    puts "    a   b   c   d   e   f   g   h  "
  end

	def valid_move?(move)
    start_pos, end_pos = parse_move(move)
    return false if start_pos.nil? || end_pos.nil?
  
    piece = @grid[start_pos[0]][start_pos[1]]
    return false if piece.nil?
  
    return false if piece.color != @current_player.color
  
    piece.valid_move?(start_pos, end_pos, self)
  end
  
  

  def parse_move(move)
    return nil if move.nil? || move.empty?

    moves = move.split(" ")
    return nil if moves.length != 2

    start_pos = parse_position(moves[0])
    end_pos = parse_position(moves[1])
    return nil if start_pos.nil? || end_pos.nil?

    [start_pos, end_pos]
  end

  def parse_position(pos)
    return nil if pos.nil? || pos.length != 2

    col = pos[0].ord - 'a'.ord
    row = 8 - pos[1].to_i
    return nil if col < 0 || col > 7 || row < 0 || row > 7

    [row, col]
  end

  def make_move(move)
    start_pos, end_pos = parse_move(move)
    return false if start_pos.nil? || end_pos.nil?

    piece = @grid[start_pos[0]][start_pos[1]]
    return false if piece.nil? || piece.color != @current_player.color

    return false unless piece.valid_move?(start_pos, end_pos, self)

    @grid[end_pos[0]][end_pos[1]] = piece
    @grid[start_pos[0]][start_pos[1]] = nil

    true
  end

  def check?(color)
    king_pos = find_king(color)
    return false if king_pos.nil?

    # Check if any opponent's pieces can attack the king
    opponent_color = (color == :white) ? :black : :white
    @grid.each_with_index do |row, row_idx|
      row.each_with_index do |piece, col_idx|
        next if piece.nil? || piece.color != opponent_color

        return true if piece.valid_move?([row_idx, col_idx], king_pos, self)
      end
    end

    false
  end

  def find_king(color)
    @grid.each_with_index do |row, row_idx|
      row.each_with_index do |piece, col_idx|
        return [row_idx, col_idx] if piece.is_a?(King) && piece.color == color
      end
    end
    nil
  end

  def checkmate?(color)
    return false unless check?(color)

    # Check if the king can move to safety
    king_pos = find_king(color)
    return false if king_pos.nil?

    @grid[king_pos[0]][king_pos[1]].moves.each do |move|
      new_board = self.dup
      new_board.make_move("#{king_pos[0]}#{king_pos[1]} #{move}")
      return false unless new_board.check?(color)
    end

    # Check if any other piece can block or capture the attacking piece
    @grid.each_with_index do |row, row_idx|
      row.each_with_index do |piece, col_idx|
        next if piece.nil? || piece.color != color

        piece.moves.each do |move|
          new_board = self.dup
          new_board.make_move("#{row_idx}#{col_idx} #{move}")
          return false unless new_board.check?(color)
        end
      end
    end

    true
  end

  def dup
    # Create a deep copy of the board
    dup_board = Marshal.load(Marshal.dump(self))
    dup_board.grid = Marshal.load(Marshal.dump(self.grid))
    dup_board
  end

  def clear_path?(start_pos, end_pos)
    start_row, start_col = start_pos
    end_row, end_col = end_pos
    path = []
  
    if start_row == end_row
      if start_col < end_col
        ((start_col + 1)...end_col).each { |col| path << [start_row, col] }
      else
        ((end_col + 1)...start_col).each { |col| path << [start_row, col] }
      end
    elsif start_col == end_col
      if start_row < end_row
        ((start_row + 1)...end_row).each { |row| path << [row, start_col] }
      else
        ((end_row + 1)...start_row).each { |row| path << [row, start_col] }
      end
    elsif (end_row - start_row).abs == (end_col - start_col).abs
      step_row = start_row < end_row ? 1 : -1
      step_col = start_col < end_col ? 1 : -1
      row, col = start_row + step_row, start_col + step_col
      while row != end_row && col != end_col
        path << [row, col]
        row += step_row
        col += step_col
      end
    else
      return false
    end
  
    path.all? { |pos| @grid[pos[0]][pos[1]].nil? }
  end
  
  
end

class Player
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def get_move
    loop do
      print "#{@color.capitalize}'s move: "
      move = gets.chomp.downcase

      if valid_move_format?(move)
        return move
      else
        puts "Invalid move format. Please enter a move in the format 'a2 a4'."
      end
    end
  end

	def valid_move_format?(move)
    move.match?(/[a-h][1-8] [a-h][1-8]/)
  end
end

class ChessGame
	attr_accessor :current_player
  def initialize
    @board = ChessBoard.new
    @players = [Player.new(:white), Player.new(:black)]
    @current_player = @players.first
  end

	def save_game(filename)
    File.open(filename, "w") do |file|
      file.write(Marshal.dump(self))
    end
    puts "Game saved to #{filename}."
  end

  def self.load_game(filename)
    File.open(filename, "r") do |file|
      Marshal.load(file.read)
    end
  end

  def play
    loop do
      puts "\nCurrent board:"
      @board.display
      puts "\n#{current_player.color.capitalize}'s turn (enter move in format 'e2 e4' or 'save' to save game):"
      move = current_player.get_move
      break if move.downcase == 'save'

      if @board.valid_move?(move)
        @board.make_move(move)
        switch_players
      else
        puts "Invalid move. Please try again."
      end

      if @board.checkmate?(@current_player.color)
        puts "\nCheckmate! #{current_player.color.capitalize} wins!"
        break
      elsif @board.check?(@current_player.color)
        puts "\nCheck!"
      end
    end
  end

  def switch_players
    @current_player = @players.find { |player| player != @current_player }
  end
end


game = ChessGame.new
game.play