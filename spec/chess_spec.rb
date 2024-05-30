require_relative '../chess'
require_relative '../pieces'

RSpec.describe ChessBoard do
  let(:board) { ChessBoard.new }

  describe '#clear_path?' do
    it 'returns true if the path is clear' do
      expect(board.clear_path?([0, 0], [0, 4])).to be true
    end

    it 'returns false if the path is not clear' do
      board.grid[0][2] = Rook.new(:white)
      expect(board.clear_path?([0, 0], [0, 4])).to be false
    end
  end

  describe '#valid_move?' do
    it 'returns true for a valid move' do
      move = 'a2 a3'
      expect(board.valid_move?(move)).to be true
    end

    it 'returns false for an invalid move' do
      move = 'a2 a5'
      expect(board.valid_move?(move)).to be false
    end
  end
end
