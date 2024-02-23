const stage = new Stage();
const SudokuGridInstance = instance.signature('Grid').atoms()[0];
const grid_width = 9;
const grid_height = 9;

//GRID
let sudokuGrid = new Grid({
    grid_location: {x: 50, y:50},
    cell_size: {x_size: 40, y_size: 40},
    grid_dimensions: {x_size: grid_width, y_size: grid_height}
})


//ADD VALUES
for (r = 0; r < grid_height; r++) {
    for (c = 0; c < grid_width; c++) {
        let cellValue = SudokuGridInstance.cells[r][c].value;
        grid.add({x: c, y: r}, new TextBox({text: cellValue.toString(), fontSize: 16, color: "black"}));
    }
}

stage.add(sudokuGrid);
stage.render(svg, document);

