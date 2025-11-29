extends Node2D
# If your root node is just Node, you can also do: extends Node

# TileMapLayer from the scene (set this in Inspector)
@export var tilemap: TileMapLayer
@export var player: CharacterBody2D

# Load generator scripts
const RoomsGenerator      = preload("res://dungeons/algorithms/rooms_generator.gd")
const BSPGenerator        = preload("res://dungeons/algorithms/bsp_generator.gd")
const MazeGenerator       = preload("res://dungeons/algorithms/maze_generator.gd")
const DrunkenGenerator    = preload("res://dungeons/algorithms/drunken_generator.gd")

# Logical tile types that generators should use
enum TileType { EMPTY, FLOOR, WALL }

# Tile atlas positions (change to match your tileset)
const TILE_FLOOR_POS := Vector2i(8, 1)
const TILE_WALL_POS  := Vector2i(2, 0)
const TILE_SOURCE_ID := 0   # usually 0 for a single atlas image

# Default dungeon size
const DUNGEON_WIDTH  := 80
const DUNGEON_HEIGHT := 80

# UI references
@onready var dungeon_type_option: OptionButton = $UI/Panel/Buttons/DungeonType
@onready var width_input: SpinBox              = $UI/Panel/Buttons/Width
@onready var height_input: SpinBox             = $UI/Panel/Buttons/Height

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

	_debug_draw_single_tile()
	if tilemap == null:
		push_warning("TileMapLayer not assigned in 'tilemap' export.")
	
	
	
func _debug_draw_single_tile() -> void:
	if tilemap == null:
		push_warning("TileMapLayer not assigned.")
		return

	var pos := Vector2i(0, 0)
	tilemap.set_cell(pos, TILE_SOURCE_ID, TILE_FLOOR_POS)
	tilemap.update_internals()
	print("Placed debug tile at ", pos)

# This is the function your Button's 'pressed' signal should call
# Make sure the signal is connected to THIS name:
#   _on_generate_button_pressed
func _on_generate_button_pressed() -> void:
	print("Pressed")
	var width: int = int(width_input.value)
	var height: int = int(height_input.value)

	var map: Array = []

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
	_draw_map(map)
	_place_player_on_floor(map)


func _draw_map(map: Array) -> void:
	if tilemap == null:
		return

	tilemap.clear()

	if map.is_empty():
		return

	for y: int in range(map.size()):
		var row: Array = map[y]
		for x: int in range(row.size()):
			var tile_type: int = row[x]
			var pos: Vector2i = Vector2i(x, y)

			match tile_type:
				TileType.EMPTY:
					tilemap.erase_cell(pos)
				TileType.FLOOR:
					tilemap.set_cell(pos, TILE_SOURCE_ID, TILE_FLOOR_POS)
				TileType.WALL:
					tilemap.set_cell(pos, TILE_SOURCE_ID, TILE_WALL_POS)

func _place_player_on_floor(map: Array) -> void:
	if player == null:
		push_warning("Player is not assigned, cannot place player.")
		return
	
	var floor_tiles: Array[Vector2i] = []

	for y: int in range(map.size()):
		var row: Array = map[y]
		for x: int in range(row.size()):
			if row[x] == TileType.FLOOR:
				floor_tiles.append(Vector2i(x, y))

	if floor_tiles.is_empty():
		push_warning("No floor tiles found to place player.")
		return

	var tile_pos: Vector2i = floor_tiles[randi() % floor_tiles.size()]
	var world_pos: Vector2 = tilemap.map_to_local(tile_pos)
	
	# Adjust for tile size to place player at the bottom-center of the tile
	# Get tile size from the tilemap
	var tile_size: Vector2i = tilemap.tile_set.tile_size
	world_pos.y += tile_size.y / 2
	
	player.global_position = world_pos
