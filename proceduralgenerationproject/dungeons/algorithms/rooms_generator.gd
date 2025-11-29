extends RefCounted

# same tile types as in main.gd: enum TileType { EMPTY, FLOOR, WALL }
const TILE_EMPTY: int = 0
const TILE_FLOOR: int = 1
const TILE_WALL: int = 2

static func generate(width: int, height: int) -> Array:
	randomize()

	# 2D array: dungeon_grid[y][x] = TILE_*
	var dungeon_grid: Array = []

	# fill with EMPTY
	for y: int in range(height):
		var row: Array = []
		for x: int in range(width):
			row.append(TILE_EMPTY)
		dungeon_grid.append(row)

	var rooms: Array[Rect2] = []
	var max_attempts: int = 100
	var tries: int = 0

	while rooms.size() < 10 and tries < max_attempts:
		var w: int = randi_range(8, 16)
		var h: int = randi_range(8, 16)

		var x: int = randi_range(1, width - w - 1)
		var y: int = randi_range(1, height - h - 1)

		var room: Rect2 = Rect2(x, y, w, h)

		var overlaps: bool = false
		for other in rooms:
			if room.grow(1).intersects(other):
				overlaps = true
				break

		if not overlaps:
			rooms.append(room)

			# carve room floors
			for iy: int in range(y, y + h):
				for ix: int in range(x, x + w):
					dungeon_grid[iy][ix] = TILE_FLOOR

			# connect to previous room with corridor
			if rooms.size() > 1:
				var prev_center: Vector2 = rooms[rooms.size() - 2].get_center()
				var curr_center: Vector2 = room.get_center()
				_carve_corridor(dungeon_grid, prev_center, curr_center, width, height)

		tries += 1

	# add walls around floors
	_add_walls(dungeon_grid, width, height)

	return dungeon_grid


static func _carve_corridor(dungeon_grid: Array, from: Vector2, to: Vector2, width: int, height: int, corridor_width: int = 2) -> void:
	var min_width: int = -corridor_width / 2
	var max_width: int = corridor_width / 2

	var from_int: Vector2i = Vector2i(int(from.x), int(from.y))
	var to_int: Vector2i = Vector2i(int(to.x), int(to.y))

	if randf() < 0.5:
		# horizontal first
		for x: int in range(min(from_int.x, to_int.x), max(from_int.x, to_int.x) + 1):
			for offset: int in range(min_width, max_width + 1):
				var y: int = from_int.y + offset
				if _is_in_bounds(x, y, width, height):
					(dungeon_grid[y] as Array)[x] = TILE_FLOOR

		# vertical
		for y: int in range(min(from_int.y, to_int.y), max(from_int.y, to_int.y) + 1):
			for offset: int in range(min_width, max_width + 1):
				var x: int = to_int.x + offset
				if _is_in_bounds(x, y, width, height):
					(dungeon_grid[y] as Array)[x] = TILE_FLOOR
	else:
		# vertical first
		for y: int in range(min(from_int.y, to_int.y), max(from_int.y, to_int.y) + 1):
			for offset: int in range(min_width, max_width + 1):
				var x: int = from_int.x + offset
				if _is_in_bounds(x, y, width, height):
					(dungeon_grid[y] as Array)[x] = TILE_FLOOR

		# horizontal
		for x: int in range(min(from_int.x, to_int.x), max(from_int.x, to_int.x) + 1):
			for offset: int in range(min_width, max_width + 1):
				var y: int = to_int.y + offset
				if _is_in_bounds(x, y, width, height):
					(dungeon_grid[y] as Array)[x] = TILE_FLOOR


static func _is_in_bounds(x: int, y: int, width: int, height: int) -> bool:
	return x >= 0 and y >= 0 and x < width and y < height


static func _add_walls(dungeon_grid: Array, width: int, height: int) -> void:
	for y: int in range(height):
		for x: int in range(width):
			if (dungeon_grid[y] as Array)[x] == TILE_FLOOR:
				for dy: int in range(-1, 2):
					for dx: int in range(-1, 2):
						var nx: int = x + dx
						var ny: int = y + dy
						if _is_in_bounds(nx, ny, width, height):
							if (dungeon_grid[ny] as Array)[nx] == TILE_EMPTY:
								(dungeon_grid[ny] as Array)[nx] = TILE_WALL
