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
    return false if piece.nil?

    @grid[end_pos[0]][end_pos[1]] = piece
    @grid[start_pos[0]][start_pos[1]] = nil

    true
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

  def play
    loop do
      puts "\nCurrent board:"
      @board.display
      puts "\n#{current_player.color.capitalize}'s turn (enter move in format 'e2 e4' or 'save' to save game):"
      move = current_player.get_move
      break if move.downcase == 'save'

      if @board.make_move(move)
        switch_players
      else
        puts "Invalid move. Please try again."
      end
    end
  end

  def switch_players
    @current_player = @players.find { |player| player != @current_player }
  end
end

game = ChessGame.new
game.play
