extends RefCounted

const TILE_EMPTY: int = 0
const TILE_FLOOR: int = 1
const TILE_WALL: int = 2

static func generate(width: int, height: int) -> Array:
	# 1) generate thin maze (1-tile-wide corridors)
	var thin_map: Array = _generate_thin_maze(width, height)
	# 2) thicken corridors by radius 1 -> approx 3 tiles wide
	var thick_map: Array = _thicken_maze(thin_map, width, height, 1)
	return thick_map


static func _generate_thin_maze(width: int, height: int) -> Array:
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

	# Visited cells
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

	var dirs: Array[Vector2i] = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1)
	]

	while stack.size() > 0:
		var current: Vector2i = stack[stack.size() - 1]

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

			# Convert cell coords to tile coords (thin)
			var x1: int = current.x * 2 + 1
			var y1: int = current.y * 2 + 1
			var x2: int = next.x * 2 + 1
			var y2: int = next.y * 2 + 1
			var xm: int = (x1 + x2) / 2
			var ym: int = (y1 + y2) / 2

			(map[y1] as Array)[x1] = TILE_FLOOR
			(map[y2] as Array)[x2] = TILE_FLOOR
			(map[ym] as Array)[xm] = TILE_FLOOR

			(visited[next.y] as Array)[next.x] = true
			stack.append(next)

	return map


static func _thicken_maze(thin_map: Array, width: int, height: int, radius: int) -> Array:
	var thick_map: Array = []

	# start with all walls
	for y: int in range(height):
		var row: Array = []
		for x: int in range(width):
			row.append(TILE_WALL)
		thick_map.append(row)

	for y: int in range(height):
		var row_thin: Array = thin_map[y]
		for x: int in range(row_thin.size()):
			if row_thin[x] == TILE_FLOOR:
				# make a small "plus" or block around this floor
				for dy: int in range(-radius, radius + 1):
					for dx: int in range(-radius, radius + 1):
						# choose shape; keep this for 3-tiles wide corridors:
						if abs(dx) + abs(dy) <= radius:
							var nx: int = x + dx
							var ny: int = y + dy
							if nx >= 0 and nx < width and ny >= 0 and ny < height:
								(thick_map[ny] as Array)[nx] = TILE_FLOOR

	return thick_map
