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

static func generate(width: int, height: int) -> Array:
	var map: Array = []

	# Start with all walls
	for y: int in range(height):
		var row: Array = []
		for x: int in range(width):
			row.append(TILE_WALL)
		map.append(row)

	var regions: Array = []
	regions.append(Region.new(1, 1, width - 2, height - 2))

	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()

	var max_regions: int = 8
	var min_size: int = 10

	# Split regions
	while regions.size() < max_regions:
		var region: Region = regions.pop_back()
		if region == null:
			break

		var split_vertical: bool = rng.randi_range(0, 1) == 0

		if split_vertical and region.w >= min_size * 2:
			var split_x: int = rng.randi_range(region.x + min_size, region.x + region.w - min_size)
			var left: Region  = Region.new(region.x, region.y, split_x - region.x, region.h)
			var right: Region = Region.new(split_x, region.y, region.x + region.w - split_x, region.h)
			regions.append(left)
			regions.append(right)
		elif not split_vertical and region.h >= min_size * 2:
			var split_y: int = rng.randi_range(region.y + min_size, region.y + region.h - min_size)
			var top: Region    = Region.new(region.x, region.y, region.w, split_y - region.y)
			var bottom: Region = Region.new(region.x, split_y, region.w, region.y + region.h - split_y)
			regions.append(top)
			regions.append(bottom)
		else:
			regions.append(region)
			if regions.size() >= max_regions:
				break

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

		var cx: int = rx + rw / 2
		var cy: int = ry + rh / 2
		centers.append(Vector2i(cx, cy))

	# Connect centers with corridors
	for i: int in range(1, centers.size()):
		var a: Vector2i = centers[i - 1]
		var b: Vector2i = centers[i]

		# Horizontal
		var x_step: int = 1 if b.x > a.x else -1
		var x: int = a.x
		while x != b.x:
			if x > 0 and x < width - 1 and a.y > 0 and a.y < height - 1:
				(map[a.y] as Array)[x] = TILE_FLOOR
			x += x_step

		# Vertical
		var y_step: int = 1 if b.y > a.y else -1
		var y: int = a.y
		while y != b.y:
			if b.x > 0 and b.x < width - 1 and y > 0 and y < height - 1:
				(map[y] as Array)[b.x] = TILE_FLOOR
			y += y_step

	return map
