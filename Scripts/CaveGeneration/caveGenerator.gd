extends Node

signal finished_generating

export(String) var world_seed = "some seed idk"
export(int) var map_width = 80
export(int) var map_height = 50
export(int) var noise_octaves = 1 
export(int) var noise_period = 10
export(float) var noise_persistence = 0.7
export(float) var noise_lacunarity = 0.2
export(float) var noise_treshold = 0.2
export(bool) var redraw setget _redraw


var tile_map : TileMap
var simplex_noise: OpenSimplexNoise = OpenSimplexNoise.new()
var rng = RandomNumberGenerator.new()
var rndmMin = 10_000_000
var rndmMax = 99_999_999

func _ready():
	rng.randomize()
	world_seed = String(rng.randi_range(rndmMin, rndmMax))
	tile_map = get_parent() as TileMap
	if tile_map == null: 
		print("rip tilemap")
		return
	clear()
	generate()
	


func _redraw(_value = null)->void:
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
	
	for x in range(-map_width / 2, map_width/2):
		for y in range(-map_height/2, map_height/2):
			if simplex_noise.get_noise_2d(x, y) < noise_treshold:
				_set_autotile(x, y)
			else:
				AutoLoad.add_spawnable(Vector2(x, y))
	tile_map.update_dirty_quadrants()
	emit_signal("finished_generating")

func _set_autotile(x: int, y:int)->void:
	tile_map.set_cell(x, y,
		tile_map.get_tileset().get_tiles_ids()[0],
		false,
		false,
		false,
		tile_map.get_cell_autotile_coord(x, y))
	tile_map.update_bitmask_area(Vector2(x, y))
