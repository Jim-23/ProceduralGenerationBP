# res://dungeons/algorithms/drunken_generator.gd
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

	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()

	var x: int = width / 2
	var y: int = height / 2
	(map[y] as Array)[x] = TILE_FLOOR

	var target_floor_count: int = int(width * height * 0.35)
	var current_floor_count: int = 1

	while current_floor_count < target_floor_count:
		var dir: int = rng.randi_range(0, 3)
		match dir:
			0:
				x += 1
			1:
				x -= 1
			2:
				y += 1
			3:
				y -= 1

		# Stay inside bounds (leave 1 tile border as walls)
		x = clamp(x, 1, width - 2)
		y = clamp(y, 1, height - 2)

		if (map[y] as Array)[x] == TILE_WALL:
			(map[y] as Array)[x] = TILE_FLOOR
			current_floor_count += 1

	return map
