# res://dungeons/algorithms/bsp_generator.gd
extends RefCounted

const TILE_EMPTY: int = 0
const TILE_FLOOR: int = 1
const TILE_WALL: int = 2


class Branch:
	var left_child: Branch
	var right_child: Branch
	var position: Vector2i
	var size: Vector2i
	var padding: Vector4i  # left, top, right, bottom padding
	
	func _init(pos: Vector2i, sz: Vector2i) -> void:
		position = pos
		size = sz
		# Random padding 2-3 tiles on each side
		var rng := RandomNumberGenerator.new()
		rng.randomize()
		padding = Vector4i(
			rng.randi_range(2, 3),  # left
			rng.randi_range(2, 3),  # top
			rng.randi_range(2, 3),  # right
			rng.randi_range(2, 3)   # bottom
		)
	
	func get_leaves() -> Array:
		if not (left_child and right_child):
			return [self]
		else:
			return left_child.get_leaves() + right_child.get_leaves()
	
	func get_center() -> Vector2i:
		return Vector2i(position.x + size.x / 2, position.y + size.y / 2)
	
	func split(remaining: int, paths: Array) -> void:
		var rng := RandomNumberGenerator.new()
		rng.randomize()
		var split_percent: float = rng.randf_range(0.3, 0.7)
		var split_horizontal: bool = size.y >= size.x  # Split horizontally if taller than wide
		
		if split_horizontal:
			# Horizontal split
			var left_height: int = int(size.y * split_percent)
			left_child = Branch.new(position, Vector2i(size.x, left_height))
			right_child = Branch.new(
				Vector2i(position.x, position.y + left_height),
				Vector2i(size.x, size.y - left_height)
			)
		else:
			# Vertical split
			var left_width: int = int(size.x * split_percent)
			left_child = Branch.new(position, Vector2i(left_width, size.y))
			right_child = Branch.new(
				Vector2i(position.x + left_width, position.y),
				Vector2i(size.x - left_width, size.y)
			)
		
		# Add path between the two child centers
		paths.push_back({
			'left': left_child.get_center(),
			'right': right_child.get_center()
		})
		
		# Recursively split children
		if remaining > 0:
			left_child.split(remaining - 1, paths)
			right_child.split(remaining - 1, paths)


static func generate(width: int, height: int) -> Array:
	var map: Array = []
	
	# Start with all EMPTY
	for y: int in range(height):
		var row: Array = []
		for x: int in range(width):
			row.append(TILE_EMPTY)
		map.append(row)
	
	# Create root branch and split it
	var root_branch := Branch.new(Vector2i(1, 1), Vector2i(width - 2, height - 2))
	var paths: Array = []
	root_branch.split(3, paths)  # 3 splits = 16 rooms
	
	# Draw rooms (leaves) with padding
	for leaf in root_branch.get_leaves():
		var padding: Vector4i = leaf.padding
		for x in range(leaf.size.x):
			for y in range(leaf.size.y):
				# Check if inside padding (creates room boundaries)
				if not _is_inside_padding(x, y, leaf, padding):
					var map_x: int = x + leaf.position.x
					var map_y: int = y + leaf.position.y
					if map_x > 0 and map_x < width - 1 and map_y > 0 and map_y < height - 1:
						(map[map_y] as Array)[map_x] = TILE_FLOOR
	
	# Draw corridors connecting rooms
	for path in paths:
		var left: Vector2i = path['left']
		var right: Vector2i = path['right']
		
		if left.y == right.y:
			# Horizontal corridor (2 tiles wide)
			for i in range(abs(right.x - left.x) + 1):
				var x: int = min(left.x, right.x) + i
				if x > 0 and x < width - 1 and left.y > 0 and left.y < height - 2:
					(map[left.y] as Array)[x] = TILE_FLOOR
					(map[left.y + 1] as Array)[x] = TILE_FLOOR
		else:
			# Vertical corridor (2 tiles wide)
			for i in range(abs(right.y - left.y) + 1):
				var y: int = min(left.y, right.y) + i
				if left.x > 0 and left.x < width - 2 and y > 0 and y < height - 1:
					(map[y] as Array)[left.x] = TILE_FLOOR
					(map[y] as Array)[left.x + 1] = TILE_FLOOR
	
	# Add walls around floor tiles
	_add_walls(map, width, height)
	return map


static func _is_inside_padding(x: int, y: int, leaf: Branch, padding: Vector4i) -> bool:
	return x < padding.x or y < padding.y or x >= leaf.size.x - padding.z or y >= leaf.size.y - padding.w


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
