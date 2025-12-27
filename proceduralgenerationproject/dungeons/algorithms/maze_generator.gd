# res://dungeons/algorithms/maze_generator.gd
extends RefCounted

const TILE_EMPTY: int = 0
const TILE_FLOOR: int = 1
const TILE_WALL: int = 2

# Direction values and their binary values
const N: int = 1
const E: int = 2
const S: int = 4
const W: int = 8

# Dictionary to map direction vectors to their corresponding wall bit
static var cell_walls := {
	Vector2i(0, -1): N,
	Vector2i(1, 0): E,
	Vector2i(0, 1): S,
	Vector2i(-1, 0): W
}

# Opposite walls for removing walls between cells
static var opposite_walls := {
	N: S,
	S: N,
	E: W,
	W: E
}


static func generate(width: int, height: int) -> Array:
	var map: Array = []
	
	# Start with all EMPTY
	for y: int in range(height):
		var row: Array = []
		for x: int in range(width):
			row.append(TILE_EMPTY)
		map.append(row)
	
	# Calculate maze cell dimensions
	# Each cell is 3 tiles wide/tall (2x2 floor + 1 wall between cells)
	# Account for 1-tile border on each side
	var cells_w: int = max(1, (width - 2) / 3)
	var cells_h: int = max(1, (height - 2) / 3)
	
	# Create grid to store wall information for each cell
	var grid: Dictionary = {}
	for y in range(cells_h):
		for x in range(cells_w):
			grid[Vector2i(x, y)] = N | E | S | W  # All walls present initially
	
	# Depth-first search maze generation
	var stack: Array[Vector2i] = []
	var current_cell := Vector2i(0, 0)
	var unvisited: Dictionary = grid.duplicate()
	unvisited.erase(current_cell)
	
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	
	while unvisited.size() > 0:
		var neighbours := _check_neighbours(current_cell, unvisited, cells_w, cells_h)
		
		if neighbours.size() > 0:
			var next: Vector2i = neighbours[rng.randi() % neighbours.size()]
			stack.append(current_cell)
			
			# Remove walls between current and next cell
			var dir: Vector2i = next - current_cell
			var current_walls: int = grid[current_cell] - cell_walls[dir]
			var next_walls: int = grid[next] - cell_walls[-dir]
			grid[current_cell] = current_walls
			grid[next] = next_walls
			
			current_cell = next
			unvisited.erase(current_cell)
		elif stack.size() > 0:
			current_cell = stack.pop_back()
		else:
			# Pick random unvisited cell if stack is empty
			if unvisited.size() > 0:
				current_cell = unvisited.keys()[0]
				unvisited.erase(current_cell)
	
	# THE GRID STORES CELLS, NOT TILES, we need to translate it to actual floor tiles
	# Convert cell grid to tile map (each cell = 2x2 tiles for player movement)
	for cell_pos in grid.keys():
		var cell_x: int = cell_pos.x
		var cell_y: int = cell_pos.y
		var walls: int = grid[cell_pos]
		
		# Each cell starts at offset 1 (border) + cell_index * 3
		var tile_x: int = 1 + cell_x * 3
		var tile_y: int = 1 + cell_y * 3
		
		# Draw 2x2 floor area for this cell
		for dy in range(2):
			for dx in range(2):
				var tx: int = tile_x + dx
				var ty: int = tile_y + dy
				if tx >= 1 and tx < width - 1 and ty >= 1 and ty < height - 1:
					(map[ty] as Array)[tx] = TILE_FLOOR
		
		# Draw corridors to neighboring cells (if walls are removed)
		# North corridor (connects to cell above)
		if not (walls & N):
			for dx in range(2):
				var tx: int = tile_x + dx
				var ty: int = tile_y - 1
				if tx >= 1 and tx < width - 1 and ty >= 1 and ty < height - 1:
					(map[ty] as Array)[tx] = TILE_FLOOR
		
		# East corridor (connects to cell on the right)
		if not (walls & E):
			for dy in range(2):
				var tx: int = tile_x + 2
				var ty: int = tile_y + dy
				if tx >= 1 and tx < width - 1 and ty >= 1 and ty < height - 1:
					(map[ty] as Array)[tx] = TILE_FLOOR
		
		# South corridor (connects to cell below)
		if not (walls & S):
			for dx in range(2):
				var tx: int = tile_x + dx
				var ty: int = tile_y + 2
				if tx >= 1 and tx < width - 1 and ty >= 1 and ty < height - 1:
					(map[ty] as Array)[tx] = TILE_FLOOR
		
		# West corridor (connects to cell on the left)
		if not (walls & W):
			for dy in range(2):
				var tx: int = tile_x - 1
				var ty: int = tile_y + dy
				if tx >= 1 and tx < width - 1 and ty >= 1 and ty < height - 1:
					(map[ty] as Array)[tx] = TILE_FLOOR
	
	# Add walls around floor tiles (this fills gaps with walls instead of leaving empty)
	_add_walls(map, width, height)
	return map


static func _check_neighbours(cell: Vector2i, unvisited: Dictionary, cells_w: int, cells_h: int) -> Array[Vector2i]:
	var list: Array[Vector2i] = []
	for dir in cell_walls.keys():
		var neighbour: Vector2i = cell + dir
		if neighbour.x >= 0 and neighbour.x < cells_w and neighbour.y >= 0 and neighbour.y < cells_h:
			if unvisited.has(neighbour):
				list.append(neighbour)
	return list


static func _add_walls(map: Array, width: int, height: int) -> void:
	for y: int in range(height):
		for x: int in range(width):
			if (map[y] as Array)[x] == TILE_FLOOR:
				for dy: int in range(-1, 2):
					for dx: int in range(-1, 2):
						var nx: int = x + dx
						var ny: int = y + dy
						if nx >= 0 and nx < width and ny >= 0 and ny < height:
							if (map[ny] as Array)[nx] == TILE_EMPTY:
								(map[ny] as Array)[nx] = TILE_WALL
