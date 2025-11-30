# res://dungeons/algorithms/bsp_generator.gd
extends RefCounted

const TILE_EMPTY: int = 0
const TILE_FLOOR: int = 1
const TILE_WALL: int = 2

class Region:
	var x: int
	var y: int
	var w: int
	var h: int

	func _init(_x: int, _y: int, _w: int, _h: int) -> void:
		x = _x
		y = _y
		w = _w
		h = _h

static func generate(width: int, height: int):
	var map: Array = []

	# Start with all EMPTY - walls will be added around floors at the end
	for y: int in range(height):
		var row: Array = []
		for x: int in range(width):
			row.append(TILE_EMPTY)
		map.append(row)

	var regions: Array = []
	regions.append(Region.new(1, 1, width - 2, height - 2))

	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()

	var max_regions: int = 8
	var min_size: int = 10

	var attempts: int = 0
	var max_attempts: int = 10

	# Split regions
	while regions.size() < max_regions and attempts < max_attempts:
		attempts += 1
	
		# Pick a random region to split instead of pop_back
		if regions.is_empty():
			break
			
		var region_index: int = rng.randi_range(0, regions.size() - 1)
		var region: Region = regions[region_index]
		regions.remove_at(region_index)

		var split_vertical: bool = rng.randi_range(0, 1) == 0
		var split_success: bool = false

		if split_vertical and region.w >= min_size * 2:
			var split_x: int = rng.randi_range(region.x + min_size, region.x + region.w - min_size)
			var left: Region  = Region.new(region.x, region.y, split_x - region.x, region.h)
			var right: Region = Region.new(split_x, region.y, region.x + region.w - split_x, region.h)
			regions.append(left)
			regions.append(right)
			split_success = true
		elif not split_vertical and region.h >= min_size * 2:
			var split_y: int = rng.randi_range(region.y + min_size, region.y + region.h - min_size)
			var top: Region    = Region.new(region.x, region.y, region.w, split_y - region.y)
			var bottom: Region = Region.new(region.x, split_y, region.w, region.y + region.h - split_y)
			regions.append(top)
			regions.append(bottom)
			split_success = true
		
		# Only add back if we couldn't split
		if not split_success:
			regions.append(region)

	# Carve rooms in regions and connect centers
	var centers: Array = []

	for region_obj in regions:
		var region2: Region = region_obj

		var room_padding: int = 1
		var rx: int = region2.x + room_padding
		var ry: int = region2.y + room_padding
		var rw: int = max(3, region2.w - room_padding * 2)
		var rh: int = max(3, region2.h - room_padding * 2)

		for y2: int in range(ry, ry + rh):
			if y2 <= 0 or y2 >= height - 1:
				continue
			for x2: int in range(rx, rx + rw):
				if x2 <= 0 or x2 >= width - 1:
					continue
				(map[y2] as Array)[x2] = TILE_FLOOR

		var cx: int = rx + int(rw * 0.5)
		var cy: int = ry + int(rh * 0.5)
		centers.append(Vector2i(cx, cy))

	# Connect centers with corridors
	for i: int in range(1, centers.size()):
		var a: Vector2i = centers[i - 1]
		var b: Vector2i = centers[i]

		# Horizontal
		var x_step: int = 1 if b.x > a.x else -1
		var x: int = a.x
		while x != b.x:
			if x > 0 and x < width - 1 and a.y > 0 and a.y < height - 2:
				(map[a.y] as Array)[x] = TILE_FLOOR
				(map[a.y + 1] as Array)[x] = TILE_FLOOR 

			x += x_step

		# Vertical
		var y_step: int = 1 if b.y > a.y else -1
		var y: int = a.y
		while y != b.y:
			if b.x > 0 and b.x < width - 1 and y > 0 and y < height - 1:
				(map[y] as Array)[b.x] = TILE_FLOOR
				(map[y + 1] as Array)[b.x + 1] = TILE_FLOOR
			y += y_step

			y += y_step

	# Add walls around floor tiles
	_add_walls(map, width, height)
	return map


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
