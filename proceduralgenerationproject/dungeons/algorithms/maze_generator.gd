# res://dungeons/algorithms/maze_generator.gd
extends RefCounted

const TILE_EMPTY: int = 0
const TILE_FLOOR: int = 1
const TILE_WALL: int = 2

static func generate(width: int, height: int) -> Array:
	var map: Array = []


	# Start with all walls
	for y: int in range(height):
		var row: Array = []
		for x: int in range(width):
			row.append(TILE_WALL)
		map.append(row)

	# Maze grid: treat every 2nd tile as a cell; between them are walls
	var cells_w: int = int((width - 1) * 0.75)
	var cells_h: int = int((height - 1) * 0.75)

	if cells_w <= 0 or cells_h <= 0:
		return map

	# Visited array for cells
	var visited: Array = []
	for cy: int in range(cells_h):
		var row_visited: Array = []
		for cx: int in range(cells_w):
			row_visited.append(false)
		visited.append(row_visited)

	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()

	var stack: Array = []
	var start: Vector2i = Vector2i(0, 0)
	stack.append(start)
	(visited[start.y] as Array)[start.x] = true

	# Directions in cell space
	var dirs: Array[Vector2i] = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1)
	]

	while stack.size() > 0:
		var current: Vector2i = stack[stack.size() - 1]

		# Collect unvisited neighbours
		var neighbours: Array[Vector2i] = []
		for d: Vector2i in dirs:
			var nx: int = current.x + d.x
			var ny: int = current.y + d.y
			if nx >= 0 and nx < cells_w and ny >= 0 and ny < cells_h:
				if not (visited[ny] as Array)[nx]:
					neighbours.append(Vector2i(nx, ny))

		if neighbours.is_empty():
			stack.pop_back()
		else:
			neighbours.shuffle()
			var next: Vector2i = neighbours[0]

			# Convert cell coords to tile coords
			var x1: int = current.x * 3 + 1
			var y1: int = current.y * 3 + 1
			var x2: int = next.x * 3 + 1
			var y2: int = next.y * 3 + 1

			for dy: int in range(2):
				for dx: int in range(2):
					if y1 + dy < height and x1 + dx < width:
						(map[y1 + dy] as Array)[x1 + dx] = TILE_FLOOR
					if y2 + dy < height and x2 + dx < width:
						(map[y2 + dy] as Array)[x2 + dx] = TILE_FLOOR
			# Carve 2-wide corridor between cells
			if x1 == x2:  # Vertical connection
				for dy: int in range(abs(y2 - y1) + 2):
					var y_pos: int = min(y1, y2) + dy
					for dx: int in range(2):
						if y_pos < height and x1 + dx < width:
							(map[y_pos] as Array)[x1 + dx] = TILE_FLOOR
			else:  # Horizontal connection
				for dx: int in range(abs(x2 - x1) + 2):
					var x_pos: int = min(x1, x2) + dx
					for dy: int in range(2):
						if y1 + dy < height and x_pos < width:
							(map[y1 + dy] as Array)[x_pos] = TILE_FLOOR


			(visited[next.y] as Array)[next.x] = true
			stack.append(next)

	return map
