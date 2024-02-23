#lang forge/bsl
option run_sterling "sudoku_vis.js"

one sig Grid {
    width: one Int,
    height: one Int,
    cells: pfunc Int -> Int -> Cell // (row, col) -> Cell
}

sig Cell {
    grid: one Grid, 
    value: one Int,
    row: one Int,
    col: one Int
    // block: one Int // 3x3 block that the cell is part of 
}



pred wellformed {
    Grid.width = 9
    Grid.height = 9 

    all row, col: Int | (row >= 0 and row <= 8 and col >= 0 and row <= 8) implies {
        some cell: Cell | Grid.cells[row][col] = cell and (cell.value >= 1 and cell.value <= 9)
    }
}

run {wellformed}
// for exactly 9 Int