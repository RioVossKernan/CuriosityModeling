#lang forge/bsl

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
    assert validPositionIndex is necessary for wellformed for 5 Int
    assert validValueIndex is necessary for wellformed for 5 Int
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
}


---ValidMove -------------------------------------------------------------------
test suite for ValidMove {

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

test suite for SudokuRules {
    assert rowRule is necessary for SudokuRules for 5 Int
    assert colRule is necessary for SudokuRules for 5 Int
    assert chunkRule is necessary for SudokuRules for 5 Int

    test expect {
        wellformedFullSolvedBoardIsPossible: {
            wellformed
            FullBoard
            SudokuRules
        } for 5 Int
        is sat
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
}