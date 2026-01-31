extends Node2D

# TileMapLayer from the scene
@export var tilemap: TileMapLayer
@export var player: CharacterBody2D

# Load generator scripts
const RoomsGenerator      = preload("res://dungeons/algorithms/rooms_generator.gd")
const BSPGenerator        = preload("res://dungeons/algorithms/bsp_generator.gd")
const MazeGenerator       = preload("res://dungeons/algorithms/maze_generator.gd")
const DrunkenGenerator    = preload("res://dungeons/algorithms/drunken_generator.gd")

# Logical tile types that generators should use
enum TileType { EMPTY, FLOOR, WALL }

# Tile atlas positions
const TILE_FLOOR_POS := Vector2i(8, 1)
const TILE_WALL_POS  := Vector2i(2, 0)
const TILE_SOURCE_ID := 0

# Default dungeon size
const DUNGEON_WIDTH  := 40
const DUNGEON_HEIGHT := 40

# UI references
@onready var dungeon_type_option: OptionButton = $UI/Panel/Buttons/DungeonType
@onready var width_input: SpinBox              = $UI/Panel/Buttons/Width
@onready var height_input: SpinBox             = $UI/Panel/Buttons/Height


class DungeonData:
	var map: Array
	var floor_tiles: Array[Vector2i]

	func _init(p_map: Array, p_floor_tiles: Array[Vector2i]) -> void:
		map = p_map
		floor_tiles = p_floor_tiles

func _ready() -> void:
	randomize()

	# Fill dropdown with dungeon types (order matters!)
	dungeon_type_option.clear()
	dungeon_type_option.add_item("Rooms")    # index 0
	dungeon_type_option.add_item("Maze")     # index 1
	dungeon_type_option.add_item("BSP")      # index 2
	dungeon_type_option.add_item("Drunken")  # index 3

	width_input.value = DUNGEON_WIDTH
	height_input.value = DUNGEON_HEIGHT


# based on the selected dungeon, you will run the algorithm which returns you a dungeon data (map, floor tiles and wall tiles)
func _on_generate_button_pressed() -> void:
	print("Pressed")
	var width: int = int(width_input.value)
	var height: int = int(height_input.value)

	var map: Array = []
	var floor_tiles: Array[Vector2i] = []

	match dungeon_type_option.selected:
		0:
			map = RoomsGenerator.generate(width, height)
		1:
			map = MazeGenerator.generate(width, height)
		2:
			map = BSPGenerator.generate(width, height)
		3:
			map = DrunkenGenerator.generate(width, height)
		_:
			push_warning("Unknown dungeon type selected.")
			return

	print("Generated map with rows: ", map.size())
	floor_tiles = _draw_map(map)
	_place_player_on_floor(floor_tiles)


func _draw_map(map: Array) -> Array[Vector2i]:
	if tilemap == null:
		return []
	var floor_tiles: Array[Vector2i] = []
	tilemap.clear()

	if map.is_empty():
		return []

	for y: int in range(map.size()):
		var row: Array = map[y]
		for x: int in range(row.size()):
			var tile_type: int = row[x]
			var pos: Vector2i = Vector2i(x, y)

			match tile_type:
				TileType.EMPTY:
					tilemap.erase_cell(pos)
				TileType.WALL:
					tilemap.set_cell(pos, TILE_SOURCE_ID, TILE_WALL_POS)
				TileType.FLOOR:
					tilemap.set_cell(pos, TILE_SOURCE_ID, TILE_FLOOR_POS)
					floor_tiles.append(pos)
				

	return floor_tiles

func _place_player_on_floor(floor_tiles: Array[Vector2i]) -> void:
	if player == null:
		push_warning("Player is not assigned, cannot place player.")
		return
	
	if floor_tiles.is_empty():
		push_warning("No floor tiles found to place player.")
		return

	# Convert floor_tiles to a set for O(1) lookup
	var floor_set: Dictionary = {}
	for tile in floor_tiles:
		floor_set[tile] = true

	# Find a 3x3 area of floor tiles and place the player in the center
	for tile in floor_tiles:
		if _is_valid_3x3_position(tile, floor_set):
			# Place player at the center of the 3x3 area (tile is top-left corner)
			var center_tile: Vector2i = tile + Vector2i(1, 1)
			var world_pos: Vector2 = tilemap.map_to_local(center_tile)
			player.global_position = world_pos
			print("Player placed at tile: ", center_tile, " (world: ", world_pos, ")")
			return

	# Fallback: if no 3x3 area found, place on a random floor tile
	push_warning("No 3x3 floor area found, placing player on random floor tile.")
	var random_tile: Vector2i = floor_tiles[randi() % floor_tiles.size()]
	player.global_position = tilemap.map_to_local(random_tile)


func _is_valid_3x3_position(top_left: Vector2i, floor_set: Dictionary) -> bool:
	# Check if all 9 tiles in a 3x3 grid starting from top_left are floor tiles
	for dy in range(3):
		for dx in range(3):
			var check_pos: Vector2i = top_left + Vector2i(dx, dy)
			if not floor_set.has(check_pos):
				return false
	return true
