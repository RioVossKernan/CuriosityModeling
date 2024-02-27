#lang forge
option run_sterling "sudoku_vis.js"

//Sudoku Board
one sig Board {
    values: pfunc Int -> Int -> Int // (row, col) -> value
}

pred wellformed {
    // For all positions with values...
    all row, col : Int | some Board.values[row][col] implies { 
        (row >= 0 and row <= 8 and col >= 0 and col <= 8) //row & col are in bounds
        (Board.values[row][col] >= 1 and Board.values[row][col] <= 9) //val is in bounds
    }
}

// There is some value at all in-bounds positions
pred FullBoard {
    all row, col : Int | {
        (row >= 0 and row <= 8 and col >= 0 and col <= 8) implies some Board.values[row][col] 
    }
}

// assesses validity of a single move
pred ValidMove[b: Board, row, col, move: Int] {
    // valid range
    row >= 0 and row <= 8 
    col >= 0 and col <= 8
    move >= 1 and move <= 9 

    no b.values[row][col] // cell must be empty
    no col2: Int | col2 != col and some b.values[row][col2] and b.values[row][col2] = move // move is not alr in same row
    no row2: Int | row2 != row and some b.values[row2][col] and b.values[row2][col] = move // move is not alr in same col

    no row2, col2: Int | {
        (divide[row2, 3] = divide[row, 3]) and (divide[col2, 3] = divide[col, 3]) // same chunk
        and some b.values[row2][col2] and b.values[row2][col2] = move // duplicate value on move
    }

}

// assesses the validity of the overall game board
pred SudokuRules{
    all row, col : Int | some Board.values[row][col] implies { 
        no col2 : Int | (Board.values[row][col] = Board.values[row][col2]) and (col2 != col) // Row Rule
        no row2 : Int | (Board.values[row][col] = Board.values[row2][col]) and (row2 != row) // Col Rule
        no row2, col2 : Int | { //Chunk Rule
            Board.values[row][col] = Board.values[row2][col2] //same number
            (col2 != col) and (row2 != row) //its a different pos
            (divide[row2,3] = divide[row,3]) and (divide[col2,3] = divide[col,3]) //same chunk
        }
    }
}

//values from a master difficulty puzzle on Sudoku.com
//input in the format of Board.values to allow for comparison.
//(row -> col -> val)
fun startBoard: Set {
    (0 -> 2 -> 8) + (0 -> 4 -> 9) + (0 -> 5 -> 3) + (0 -> 7 -> 7) + (0 -> 8 -> 2) +
    (1 -> 6 -> 3) +
    (2 -> 1 -> 1) + (2 -> 5 -> 6) +
    (3 -> 2 -> 4) + (3 -> 6 -> 5) +
    (4 -> 4 -> 3) + (4 -> 6 -> 8) +
    (5 -> 0 -> 6) + (5 -> 5 -> 9) + (5 -> 7 -> 4) + (5 -> 8 -> 3) +
    (6 -> 2 -> 7) + (6 -> 4 -> 2) + (6 -> 7 -> 9) + (6 -> 8 -> 4) +
    (7 -> 0 -> 8) + (7 -> 3 -> 7) +
    (8 -> 7 -> 5)
}

//Finds a full board from the starting parameter values
//values is a integer set of arity 3, (row, col, val)
pred solve[initVals : values]{
    FullBoard
    initVals in Board.values //each value from the start is also in the solved
}

//produces a wellformed, valid, full, solved board based on the startBoard puzzle taken from Sudoku.com 
run {
    wellformed
    SudokuRules
    solve[startBoard]
} for 5 Int