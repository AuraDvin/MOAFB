extends Node2D

signal removeBlocks(atPosition)

var rng = RandomNumberGenerator.new()
var mob_scene = preload("res://Scripts/Enemy/enemy.tscn")
var player_scene = preload("res://Scripts/Player/player.tscn")
var mobs_spawned = 0

func _ready():
	rng.randomize()
	# AutoLoad.auraLog("cave script ready")

#func _event(event):
#	if event is InputEventKey:
#		if event.is_action_pressed("ui_left"):
#			$Camera2D.x -= 10
#		if event.is_action_pressed("ui_right"):
#			$Camera2D.x += 10
#		if event.is_action_pressed("ui_down"):
#				$Camera2D.y += 10
#		if event.is_action_pressed("ui_up"):
#			$Camera2D.y -= 10

func _on_TempTileMap_script_done():
	var last_index = AutoLoad.get_last_spawnable_index()
	var old_mob_count = -1

	if last_index == null or last_index == NAN:
		AutoLoad.auraLog("rip")
		return

	var last_spawn = [AutoLoad.spawnable_locations[0]]
	var player_spawn = AutoLoad.spawnable_locations[0]
	AutoLoad.spawnable_locations.remove(0)
	spawn_player(player_spawn)

	for i in range(10):
		rng.randomize()
		var index = rng.randi_range(1, last_index)
		var spawn_position = AutoLoad.spawnable_locations[index]
		for j in last_spawn:
			if j.x - spawn_position.x > 400:
#				AutoLoad.auraLog("true")
				mobs_spawned += 1
				spawn_mob(spawn_position)
				AutoLoad.spawnable_locations.remove(spawn_position)
				break
		if abs(old_mob_count - mobs_spawned) <= 0:
			i -= 1
		else:
			old_mob_count = mobs_spawned
		if i < 0:
			print(i)
#	$Camera2D.set_global_position(spawn_position)

func spawn_mob(location):
	var mob = mob_scene.instance()
	call_deferred("add_child", mob)
	mob.set_global_position(location)

func spawn_player(location):
	var player = player_scene.instance()
	call_deferred("add_child", player)
	for x in range(8):
		for y in range(8):
			var mapX = location.x - x if x < 4 else location.x + x
			var mapY = location.y - y if y < 4 else location.y + y
			var position = Vector2(mapX, mapY)
			emit_signal("removeBlocks", position)

#	player.set_global_position(location)




