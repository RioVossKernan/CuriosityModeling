const stage = new Stage()
const Box = instance.signature('Grid').atoms()[0]
const grid_width = parseInt(Box.join(width))
const grid_height = parseInt(Box.join(height))

//GRID
let grid = new Grid({
    grid_location: {x: 50, y:50},
    cell_size: {x_size: 40, y_size: 40},
    grid_dimensions: {x_size: grid_width, y_size: grid_height}
})

//ADD VALUES
for (r = 0; r < grid_height; r++) {
    for (c = 0; c < grid_width; c++) {
        grid.add({x: c, y: r}, new TextBox({text: `${Box.places[r][c].toString().substring(0,1)}`, fontSize: 16, color: "black"}))
    }
}

stage.add(grid)
stage.render(svg, document)