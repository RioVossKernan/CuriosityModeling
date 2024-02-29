#lang forge

open "sudoku.frg"

---WELLFORMED ------------------------------------------------------------------
pred validPositionIndex {
    all row, col: Int | some Board.values[row][col] implies {
        (row >= 0 and row <= 8) and (col >= 0 and col <= 8)
    }
}

pred validValueIndex {
    all row, col: Int | some Board.values[row][col] implies {
        Board.values[row][col] >= 1 
        Board.values[row][col] <= 9
    }
}

-- overconstraint
pred overConstrainedRow {
    // the original constraints
    all row, col : Int | some Board.values[row][col] implies {
        (row >= 0 and row <= 8 and col >= 0 and col <= 8) // row & col are in bounds
        (Board.values[row][col] >= 1 and Board.values[row][col] <= 9) // val is in bounds
    }
    // now overconstraints: 
    // each row contains exactly one of each value from 1 to 9
    all row: Int | row >= 0 and row <= 8 implies {
        all val: Int | val >= 1 and val <= 9 implies {
            one col: Int | col >= 0 and col <= 8 and Board.values[row][col] = val
        }
    }
}

pred overConstrainedCol {
    // the original constraints
    all row, col : Int | some Board.values[row][col] implies {
        (row >= 0 and row <= 8 and col >= 0 and col <= 8) // row & col are in bounds
        (Board.values[row][col] >= 1 and Board.values[row][col] <= 9) // val is in bounds
    }
    // now overconstraints: 
    // each col contains exactly one of each value from 1 to 9
    all col : Int | col >= 0 and col <= 8 implies {
        all val : Int | val >= 1 and val <= 9 implies {
            one row : Int | row >= 0 and row <= 8 and Board.values[row][col] = val
        }
    }
}

test suite for wellformed {
    assert validValueIndex is necessary for wellformed for 5 Int
    assert validPositionIndex is necessary for wellformed for 5 Int
    assert overConstrainedRow is sufficient for wellformed for 5 Int
    assert overConstrainedCol is sufficient for wellformed for 5 Int

    test expect {
        wellformedIsPossible: {
            wellformed
        } for 5 Int
        is sat
    }
}

---FullBoard -------------------------------------------------------------------
pred hasValues {
    all row, col: Int | (row >= 0 and row <= 8 and col >= 0 and col <= 8) implies some Board.values[row][col]
}

-- overconstraint 
pred oneValuePerCell {
    all row, col: Int | (row >= 0 and row <= 8 and col >= 0 and col <= 8) implies one Board.values[row][col]
}

-- helper
fun zeroToEight: Set {
    0 + 1 + 2 + 3 + 3 + 4 + 5 + 6 + 7 + 8
}

test suite for FullBoard {
    assert hasValues is necessary for FullBoard for 5 Int
    assert oneValuePerCell is sufficient for FullBoard for 5 Int

    test expect {
        wellformedFullBoardIsPossible: {
            wellformed
            FullBoard
        } for 5 Int
        is sat
    }

    // a board with empty cells should not be full
    test expect {
        emptyBoardIsNotFull: {
            all row, col: zeroToEight | no Board.values[row][col]
            not FullBoard
        } for 5 Int
        is sat 
    }

    // a board with 1+ cells empty isn't considered FullBoard
    test expect {
        partiallyFilledBoardIsNotFull: {
            some row, col: zeroToEight | no Board.values[row][col] // at least one cell is empty
            not FullBoard
        } for 5 Int
        is sat 
    }

    // a board with invalid values shouldn't be considered Full
    test expect {
        invalidValuesIsNotFull: {
            some row, col: zeroToEight | (Board.values[row][col] < 1 or Board.values[row][col] > 9) // invalid values
            not FullBoard
        } for 5 Int
        is sat
    }

}

---SudokuRules -----------------------------------------------------------------
pred rowRule{
    all row, col : Int | some Board.values[row][col] implies { 
        no col2 : Int | (Board.values[row][col] = Board.values[row][col2]) and (col2 != col) // Row Rule
    }
}
pred colRule{
    all row, col : Int | some Board.values[row][col] implies { 
        no row2 : Int | (Board.values[row][col] = Board.values[row2][col]) and (row2 != row) // Col Rule
    }
}
pred chunkRule{
    all row, col : Int | some Board.values[row][col] implies { 
        no row2, col2 : Int | { //Chunk Rule
            Board.values[row][col] = Board.values[row2][col2] //same number
            (col2 != col) and (row2 != row) //its a different pos
            (divide[row2,3] = divide[row,3]) and (divide[col2,3] = divide[col,3]) //same chunk
        }
    }
}

pred fullSudoku {
    wellformed
    SudokuRules
    FullBoard
}

test suite for fullSudoku {
    assert rowRule is necessary for fullSudoku for 5 Int
    assert colRule is necessary for fullSudoku for 5 Int
    assert chunkRule is necessary for fullSudoku for 5 Int

    test expect {
        wellformedFullSolvedBoardIsPossible: {
            fullSudoku
        } for 5 Int
        is sat
    }

    test expect {
        rowRuleViolationIsUnsat: {
            fullSudoku
            // two cells in the same row with the same value
            some row, col1, col2: zeroToEight | {
                col1 != col2
                some Board.values[row][col1]
                Board.values[row][col1] = Board.values[row][col2]
            }
            not rowRule
        } for 5 Int
        is unsat 
    }

    test expect {
        colRuleViolationIsUnsat: {
            fullSudoku
            // two cells in the same row with the same value
            some col, row1, row2: zeroToEight | {
                row1 != row2
                some Board.values[col][row1]
                Board.values[col][row1] = Board.values[col][row2]
            }
            not colRule
        } for 5 Int
        is unsat 
    }

    test expect {
        chunkRuleViolationIsUnsat: {
            fullSudoku
            // two cells in the same chunk with the same value
            some row1, col1, row2, col2: zeroToEight | {
                (divide[row1, 3] = divide[row2, 3]) and (divide[col1, 3] = divide[col2, 3]) 
                (row1 != row2 or col1 != col2) 
                some Board.values[row1][col1]
                Board.values[row1][col1] = Board.values[row2][col2]
            }
            not chunkRule
        } for 5 Int
        is unsat
    }
}

---Solve -----------------------------------------------------------------
test suite for solve {

    test expect {
        solveIsSatisfiable: {
            wellformed
            FullBoard
            SudokuRules
            solve[startBoard]
        } for 5 Int
        is sat
    }

    // all initial numbers should remain unchanged in the solution
    test expect {
        solutionPreservesInitialClues: {
            solve[startBoard]
            startBoard in Board.values
        } for 5 Int
        is sat 
    }
}