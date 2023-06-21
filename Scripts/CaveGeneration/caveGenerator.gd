extends Node

#signal finished_generating
signal new_world_position_of_smart_cursor (new_position_of_cursor)
#signal moment(x,y)

const MISSING_TILE_MAP_ERROR = "Tile Map is not defined! Make sure to set this scene as a child of a tile map node in your tree"
const SMART_CURSOR = preload("res://Assets/smart-cursor-64.png")
const ORE_TEXTURE = preload("res://Assets/gold.png")

export (String) var world_seed = "some seed"
export (int) var map_width = 80
export (int) var map_height = 50
export (int) var noise_octaves = 1
export (int) var noise_period = 10
export (float) var noise_persistence = 0.7
export (float) var noise_lacunarity = 0.2
export (float) var noise_treshold = 0.2
export (bool) var redraw setget _redraw
# export (float) var noise_gold_treshold = 0.001

var tile_map: TileMap
var simplex_noise: OpenSimplexNoise = OpenSimplexNoise.new()
var rng = RandomNumberGenerator.new()
var rndmMin = 10000000  # 10_000_000
var rndmMax = 99999999  # 99_999_999
var smart_cursor
var gold_locations = []
var banana = []

class test:
	static func moment (a, b) -> bool:
		if a.x > b.x or (a.x == b.x and a.y > b.y): 
			return true
		return false
# debug
#var debug_sprite = preload("res://icon.png") # neki

func _ready():
#	print_debug("cave generator ready")
	rng.randomize()
	world_seed = String(rng.randi_range(rndmMin, rndmMax))
	tile_map = get_parent() as TileMap
	if tile_map == null:
		print_debug(MISSING_TILE_MAP_ERROR)
		return
	clear()
	generate()
	define_smart_cursor()


func define_smart_cursor():
	smart_cursor = Sprite.new()
	smart_cursor.texture = SMART_CURSOR
	smart_cursor.centered = false
	smart_cursor.z_index = 2
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
	
	rng.randomize()
	for _i in range(5000):
		var newPosition = Vector2(rng.randi_range(-map_width * 0.5, map_width * 0.5), rng.randi_range(-map_height * 0.5, map_height * 0.5))
		if not gold_locations.has(newPosition):
			gold_locations.push_back(newPosition)
		else:
			var newNewPosition = newPosition
			var iteration = 0
			while(gold_locations.has(newNewPosition)):
				newNewPosition.x += 4
				if (iteration > 4): 
					newNewPosition.x = newPosition.x
					newNewPosition.y += 4
			gold_locations.push_back(newNewPosition)
	gold_locations.sort_custom(test, "moment")

	for x in range(-map_width * 0.5, map_width * 0.5):
		for y in range(-map_height * 0.5, map_height * 0.5):
			var value = simplex_noise.get_noise_2d(x, y)
			if value < noise_treshold:
				_set_autotile(x, y)
				var tile_position = Vector2(x, y) * 0.25 * tile_map.cell_size
				if gold_locations.has(tile_position) and banana.size() < 50:
					var gold_ore_moment = Sprite.new()
					var local = tile_map.to_local(tile_position)
					var world = tile_map.map_to_world(local)
					var global = tile_map.to_global(world)  
					
					gold_ore_moment.name = str(global)
					gold_ore_moment.scale *= 2
					gold_ore_moment.texture = ORE_TEXTURE
					gold_ore_moment.centered = false
					gold_ore_moment.z_index = 2
					gold_ore_moment.set_global_position(global)
					gold_locations.erase(tile_position)
					
					banana.push_back(global)
					
					call_deferred("add_child", gold_ore_moment)
			else:
				AutoLoad.add_spawnable(Vector2(x, y))

	tile_map.update_dirty_quadrants()
	# for x in range(10):
	# 	for y in range(10):
	# 		var tile_position = Vector2(x, y) * 0.25 * tile_map.cell_size
	# 		var gold_ore_moment = Sprite.new()
	# 		var local = tile_map.to_local(tile_position)
	# 		var world = tile_map.map_to_world(local)
	# 		var global = tile_map.to_global(world)  + Vector2(0, 2 * tile_map.cell_size.y - 4)

	# 		gold_ore_moment.scale *= 2
	# 		gold_ore_moment.texture = ORE_TEXTURE
	# 		gold_ore_moment.centered = false
	# 		gold_ore_moment.z_index = 2

	# 		# gold_ore_moment.set_global_position(local)
	# 		gold_ore_moment.set_global_position(global)
	# 		get_tree().get_root().call_deferred("add_child", gold_ore_moment)
	# print_debug(moments)
#	emit_signal("finished_generating")

# var moments = []

# func _on_caveGenerator_moment(x,y):
# 	var sx = tile_map.to_local(Vector2(x,y)).x
# 	var sy = tile_map.to_local(Vector2(x,y)).y
	
# 	x = sx
# 	y = sy

# 	var cellvalue = tile_map.get_cellv(Vector2(x, y))
# 	moments.push_back(cellvalue)
# 	if cellvalue != -1:
# 		var tile_position = Vector2(x, y - 2) * 0.25 * tile_map.cell_size
# 		var gold_ore_moment = Sprite.new()
# 		var local = tile_map.to_local(tile_position)
# 		var world = tile_map.map_to_world(local)
# 		var global = tile_map.to_global(world)  + Vector2(0, 2 * tile_map.cell_size.y - 4)

# 		gold_ore_moment.scale *= 2
# 		gold_ore_moment.texture = ORE_TEXTURE
# 		gold_ore_moment.centered = false
# 		gold_ore_moment.z_index = 2

# 		# gold_ore_moment.set_global_position(local)
# 		gold_ore_moment.set_global_position(global)
# 		get_tree().get_root().call_deferred("add_child", gold_ore_moment)

func _set_autotile(x: int, y: int) -> void:
	tile_map.set_cell(x, y,
		tile_map.get_tileset().get_tiles_ids()[0],
		false,
		false,
		false,
		tile_map.get_cell_autotile_coord(x, y))
	tile_map.update_bitmask_area(Vector2(x, y))
#	emit_signal("moment",x,y)

func _removeTile(x: int, y: int) -> void:
	var global = Vector2(x, y)
	var local = tile_map.to_local(global)
	var position = tile_map.world_to_map(local)
	
	# Delete the local tile
	tile_map.set_cell(position.x, position.y, -1)
	tile_map.update_bitmask_area(position)
	
	# Now to get the position of the tile in real world 
	var world_location = tile_map.map_to_world(position)
	var global_location = tile_map.to_global(world_location)
		
	if banana.has(global_location):
		banana.erase(banana[banana.find(global_location)])
		get_node("./" + str(global_location)).queue_free()
		AutoLoad.addGold()

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
	emit_signal("new_world_position_of_smart_cursor", global)
	

func _on_Player_cursor_visibility(yes):
	smart_cursor.visible = yes

func _on_tempScene_clear_area_around_player_spawn(spawn_location):
	var map = tile_map.world_to_map(spawn_location)
	var location = tile_map.to_local(map)
	for x in range (location.x - 4, location.x + 4):
		for y in range(location.y - 4, location.y + 4):
			tile_map.set_cell(x, y, -1)
			tile_map.update_bitmask_area(Vector2(x,y))
			y += 1
		x += 1
#	print_debug("Finished")

