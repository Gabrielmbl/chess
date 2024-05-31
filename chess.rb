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

  def clear_path?(start_pos, end_pos)
    dx = end_pos[0] <=> start_pos[0]
    dy = end_pos[1] <=> start_pos[1]
    curr_pos = [start_pos[0] + dx, start_pos[1] + dy]

    while curr_pos != end_pos
      return false unless @grid[curr_pos[0]][curr_pos[1]].nil?

      curr_pos = [curr_pos[0] + dx, curr_pos[1] + dy]
    end

    true
  end

  def in_check?(color)
    king_pos = find_king(color)
    @grid.each_with_index do |row, i|
      row.each_with_index do |piece, j|
        next if piece.nil? || piece.color == color
        return true if piece.valid_move?([i, j], king_pos, self)
      end
    end
    false
  end

  def checkmate?(color)
    return false unless in_check?(color)
    @grid.each_with_index do |row, i|
      row.each_with_index do |piece, j|
        next if piece.nil? || piece.color != color
        piece.possible_moves([i, j], self).each do |move|
          return false unless move_into_check?([i, j], move)
        end
      end
    end
    true
  end

  def find_king(color)
    @grid.each_with_index do |row, i|
      row.each_with_index do |piece, j|
        return [i, j] if piece.is_a?(King) && piece.color == color
      end
    end
    nil
  end

  def move_into_check?(start_pos, end_pos)
    piece = @grid[start_pos[0]][start_pos[1]]
    captured_piece = @grid[end_pos[0]][end_pos[1]]
    @grid[end_pos[0]][end_pos[1]] = piece
    @grid[start_pos[0]][start_pos[1]] = nil
    in_check = in_check?(piece.color)
    @grid[start_pos[0]][start_pos[1]] = piece
    @grid[end_pos[0]][end_pos[1]] = captured_piece
    in_check
  end

  def make_move(move)
    start_pos, end_pos = parse_move(move)
    return false if start_pos.nil? || end_pos.nil?

    piece = @grid[start_pos[0]][start_pos[1]]
    if piece.nil?
      puts "No piece at starting position #{start_pos}. Move is invalid."
      return false
    end

    unless piece.color == current_player.color
      puts "It's not your turn. Move is invalid."
      return false
    end

    if move_into_check?(start_pos, end_pos)
      puts "Move would place you in check. Move is invalid."
      return false
    end

    @grid[end_pos[0]][end_pos[1]] = piece
    @grid[start_pos[0]][start_pos[1]] = nil

    true
  end

  def promote_pawn(pos)
    row, col = pos
    return unless [0, 7].include?(row)

    puts "Pawn promotion! Choose a piece: (Q)ueen, (R)ook, (B)ishop, or (K)night"
    choice = gets.chomp.upcase
    case choice
    when 'Q'
      @grid[row][col] = Queen.new(@grid[row][col].color)
    when 'R'
      @grid[row][col] = Rook.new(@grid[row][col].color)
    when 'B'
      @grid[row][col] = Bishop.new(@grid[row][col].color)
    when 'K'
      @grid[row][col] = Knight.new(@grid[row][col].color)
    else
      puts "Invalid choice, promoting to Queen by default."
      @grid[row][col] = Queen.new(@grid[row][col].color)
    end
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
      if @board.checkmate?(current_player.color)
        puts "Checkmate! #{current_player.color.capitalize} loses."
        break
      elsif @board.in_check?(current_player.color)
        puts "Check! #{current_player.color.capitalize} is in check."
      end
      puts "\n#{current_player.color.capitalize}'s turn (enter move in format 'e2 e4' or 'save' to save game):"
      move = current_player.get_move
      break if move.downcase == 'save'

      if @board.make_move(move)
        # Promote pawn if it reaches the end
        @board.promote_pawn(@board.parse_move(move).last)
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
