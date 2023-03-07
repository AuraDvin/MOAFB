extends Node

var test = 0
var doLog = true
#var rng = RandomNumberGenerator.new()
var spawnable_locations = []

func _ready():
	pass # Replace with function body.

func increase_test(amount = 1):
	test += amount
	print(test)

func add_spawnable(location: Vector2):
	var above = Vector2(location.x, location.y - 1)
	var below = Vector2(location.x, location.y + 1)
	
	if spawnable_locations.has(above): # nad njim
		spawnable_locations.erase(above)
		spawnable_locations.append(location)
	elif not spawnable_locations.has(below): # pod njim
		spawnable_locations.append(location)

func show_spawnable():
	for i in spawnable_locations:
		print(i)

func get_last_spawnable_index():
	return spawnable_locations.size() - 1

func auraLog(any):
	if doLog:
		print(any)