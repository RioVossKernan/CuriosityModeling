#lang forge/bsl
option run_sterling "magic_box_vis.js"

one sig Grid {
    width: one Int,
    height: one Int,
    places: pfunc Int -> Int -> Int
}

pred wellformed{
    Grid.width > 0
    Grid.height > 0

    all row, col : Int | (row >= 0 and row < Grid.height and col >= 0 and col < Grid.width) implies {
        some val: Int | Grid.places[row][col] = val 
    }
}

run {wellformed} for exactly 4 Int