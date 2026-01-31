# res://dungeons/algorithms/drunken_generator.gd
extends RefCounted

const TILE_EMPTY: int = 0
const TILE_FLOOR: int = 1
const TILE_WALL: int = 2

static func generate(width: int, height: int) -> Array:
	var map: Array = []

	# Start with all EMPTY - walls will be added around flooors at the end
	for y: int in range(height):
		var row: Array = []
		for x: int in range(width):
			row.append(TILE_EMPTY)
		map.append(row)

	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()

	var x: int = int(width * 0.5) # using * 0.5 instead of / 2 so we dont get a warning about float to int conversion
	var y: int = int(height * 0.5) # using * 0.5 instead of / 2 so we dont get a warning about float to int conversion

	(map[y] as Array)[x] = TILE_FLOOR

	var target_floor_count: int = int(width * height * 0.35)
	var current_floor_count: int = 1

	# Carve initial 3x3 area at starting position for guaranteed spawn point
	current_floor_count += _carve_3x3(map, x - 1, y - 1, width, height)

	var steps_since_room: int = 0

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

		# Stay inside bounds (leave 3 tile border for 3x3 carving)
		x = clamp(x, 2, width - 4)
		y = clamp(y, 2, height - 4)

		steps_since_room += 1

		# Every 15-25 steps, carve a 3x3 area to create small rooms
		if steps_since_room > rng.randi_range(15, 25):
			current_floor_count += _carve_3x3(map, x - 1, y - 1, width, height)
			steps_since_room = 0
		else:
			# Carve a 2x2 area for corridors
			current_floor_count += _carve_2x2(map, x, y, width, height)

	# Add walls around floor tiles
	_add_walls(map, width, height)
	return map


static func _carve_3x3(map: Array, x: int, y: int, width: int, height: int) -> int:
	var carved_count: int = 0
	for dy in range(3):
		for dx in range(3):
			var nx: int = x + dx
			var ny: int = y + dy
			if nx > 0 and nx < width - 1 and ny > 0 and ny < height - 1:
				if (map[ny] as Array)[nx] != TILE_FLOOR:
					(map[ny] as Array)[nx] = TILE_FLOOR
					carved_count += 1
	return carved_count


static func _carve_2x2(map: Array, x: int, y: int, width: int, height: int) -> int:
	var carved_count: int = 0
	for dy in range(2):
		for dx in range(2):
			var nx: int = x + dx
			var ny: int = y + dy
			if nx > 0 and nx < width - 1 and ny > 0 and ny < height - 1:
				if (map[ny] as Array)[nx] != TILE_FLOOR:
					(map[ny] as Array)[nx] = TILE_FLOOR
					carved_count += 1
	return carved_count


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
