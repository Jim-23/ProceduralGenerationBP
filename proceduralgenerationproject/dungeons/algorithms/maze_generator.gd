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
	var cells_w: int = int((width - 1) / 2)
	var cells_h: int = int((height - 1) / 2)

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
			var x1: int = current.x * 2 + 1
			var y1: int = current.y * 2 + 1
			var x2: int = next.x * 2 + 1
			var y2: int = next.y * 2 + 1

			(map[y1] as Array)[x1] = TILE_FLOOR
			(map[y2] as Array)[x2] = TILE_FLOOR
			(map[(y1 + y2) / 2] as Array)[(x1 + x2) / 2] = TILE_FLOOR

			(visited[next.y] as Array)[next.x] = true
			stack.append(next)

	return map
