extends Node

signal addedGold (amount)

var doLog = false
var gold = 200
var spawnable_locations = []

func _ready():
	pass  # Replace with function body.

func add_spawnable(location: Vector2):
	var above = Vector2(location.x, location.y - 1)
	var below = Vector2(location.x, location.y + 1)

	if spawnable_locations.has(above): # nad njim
		spawnable_locations.erase(above)
		spawnable_locations.append(location)
	elif not spawnable_locations.has(below): # pod njim
		spawnable_locations.append(location)

func show_spawnable():
	pass

func get_last_spawnable_index():
	return spawnable_locations.size() - 1

func addGold():
	gold += 1
	emit_signal("addedGold", gold)

func getGold():
	return gold
