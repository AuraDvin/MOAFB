extends Node

signal finished_generating

const MISSING_TILE_MAP_ERROR = "Tile Map is not defined! Make sure to set this scene as a child of a tile map node in your tree"
const SMART_CURSOR = preload("res://Assets/smart-cursor-64.png")

export (String) var world_seed = "some seed"
export (int) var map_width = 80
export (int) var map_height = 50
export (int) var noise_octaves = 1
export (int) var noise_period = 10
export (float) var noise_persistence = 0.7
export (float) var noise_lacunarity = 0.2
export (float) var noise_treshold = 0.2
export (bool) var redraw setget _redraw

var tile_map:TileMap
var simplex_noise:OpenSimplexNoise = OpenSimplexNoise.new()
var rng = RandomNumberGenerator.new()
var rndmMin = 10000000 # 10_000_000
var rndmMax = 99999999 # 99_999_999
var smart_cursor
# debug
#var debug_sprite = preload("res://icon.png") # neki

func _ready():
#	print("cave generator ready")
	rng.randomize()
	world_seed = String(rng.randi_range(rndmMin, rndmMax))
	tile_map = get_parent() as TileMap
	if tile_map == null:
		print(MISSING_TILE_MAP_ERROR)
		return
	clear()
	generate()
	smart_cursor= Sprite.new()
	smart_cursor.texture = SMART_CURSOR
	smart_cursor.centered = false
#	get_tree().get_root().add_child(smart_cursor)
	call_deferred("add_child", smart_cursor)

func _redraw(_value = null) -> void:
	if tile_map == null:
		return
	clear()
	generate()

func clear() -> void:
	tile_map.clear()

func generate() -> void:
	simplex_noise.seed = world_seed.hash()
	simplex_noise.octaves = noise_octaves
	simplex_noise.period = noise_period
	simplex_noise.persistence = noise_persistence
	simplex_noise.lacunarity = noise_lacunarity

	for x in range(-map_width / 2, map_width / 2):
		for y in range(-map_height / 2, map_height / 2):
			if simplex_noise.get_noise_2d(x, y) < noise_treshold:
				_set_autotile(x, y)
			else :
				AutoLoad.add_spawnable(Vector2(x, y))
	tile_map.update_dirty_quadrants()
	emit_signal("finished_generating")

func _set_autotile(x:int, y:int) -> void:
	tile_map.set_cell(x, y,
		tile_map.get_tileset().get_tiles_ids()[0],
		false,
		false,
		false,
		tile_map.get_cell_autotile_coord(x, y))
	tile_map.update_bitmask_area(Vector2(x, y))

func _removeTile(x:int, y:int) -> void:
	var local = tile_map.to_local(Vector2(x, y))
	var position = tile_map.world_to_map(local)
	tile_map.set_cell(position.x, position.y, -1)
	tile_map.update_bitmask_area(position)


func _on_Player_mine_block(x, y, direction):
	if direction.x > 0:
		x -= 1
	if direction.y > 0:
		y -= 1
	_removeTile(x, y)


func _on_Player_move_smart_cursor(position, direction):
	if direction.x > 0:
		position.x -= 1
	if direction.y > 0:
		position.y -= 1
	var local = tile_map.to_local(position)
	var tile = tile_map.world_to_map(local)
	var world = tile_map.map_to_world(tile)
	var global = tile_map.to_global(world)
	smart_cursor.set_global_position(global)
	
func _on_Player_cursor_visibility(yes):
	smart_cursor.visible = yes
