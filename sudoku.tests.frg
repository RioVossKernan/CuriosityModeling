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
    assert validPositionIndex is necessary for wellformed
    assert validValueIndex is necessary for wellformed
    assert overConstrainedRow is sufficient for wellformed
    assert overConstrainedCol is sufficient for wellformed
}

---FullBoard -------------------------------------------------------------------
pred hasValues {
    all row, col: Int | (row >= 0 and row <= 8 and col >= 0 and col <= 8) implies some Board.values[row][col]
}

pred validRange {
    all row, col: Int | not ((row < 0 or row > 8 or col < 0 or col > 8) and some Board.values[row][col])
}

-- overconstraint since this wasn't explicitly defined in FullBoard? 
pred oneValuePerCell {
    all row, col: Int | (row >= 0 and row <= 8 and col >= 0 and col <= 8) implies lone Board.values[row][col]
}

test suite for FullBoard {
    assert hasValues is necessary for FullBoard
    assert validRange is sufficient for FullBoard
    assert oneValuePerCell is sufficient for FullBoard
}


---ValidMove -------------------------------------------------------------------

test suite for ValidMove {

}


---SudokuRules -----------------------------------------------------------------
test suite for SudokuRules {

}