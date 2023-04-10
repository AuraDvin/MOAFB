extends Node
#
#const MAX_VOLUME = 2 #db
#const MIN_VOLUME = -400 #db
#
#var test = 0
var doLog = false
#var rng = RandomNumberGenerator.new()
var spawnable_locations = [Vector2.ZERO]
#var music_volume = 0.40
#var music_muted = false

#onready var music_player = $MusicPlayer

func _ready():
	pass  # Replace with function body.

#func increase_test(amount = 1):
#	test += amount
#	print(test)

func add_spawnable(_location: Vector2):
	pass
#	var above = Vector2(location.x, location.y - 1)
#	var below = Vector2(location.x, location.y + 1)
#
#	if spawnable_locations.has(above): # nad njim
#		spawnable_locations.erase(above)
#		spawnable_locations.append(location)
#	elif not spawnable_locations.has(below): # pod njim
#		spawnable_locations.append(location)

func show_spawnable():
	pass
#	for i in spawnable_locations:
#		print(i)

func get_last_spawnable_index():
	return spawnable_locations.size() - 1

func auraLog(_any):
	pass
#	if false:
#		print(any)
