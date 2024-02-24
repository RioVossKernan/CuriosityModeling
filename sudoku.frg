#lang forge/bsl
option run_sterling "sudoku_vis.js"

//Sudoku Board
one sig Board {
    values: pfunc Int -> Int -> Int // (row, col) -> individual cell
}

pred wellformed {
    //For all positions with values...
    all row, col : Int | some Board.values[row][col] implies { 
        (row >= 0 and row <= 8 and col >= 0 and col <= 8) //row & col are in bounds
        (Board.values[row][col] >= 1 and Board.values[row][col] <= 9) //val is in bounds
    }
}

pred FullBoard{
    all row, col : Int | {
        (row >= 0 and row <= 8 and col >= 0 and col <= 8) implies some Board.values[row][col] 
    }
}

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

run {
    wellformed
    FullBoard
    SudokuRules
} for 5 Int