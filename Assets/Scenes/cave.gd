extends Node2D

var rng = RandomNumberGenerator.new()
var mob_scene = preload("res://Scripts/Enemy/enemy.tscn")
var mobs_spawned = 0

func _ready():
	rng.randomize()
	pass 


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

func _on_caveGenerator_finished_generating():
	var last_index = AutoLoad.get_last_spawnable_index()
	var old_mob_count = -1
	
	if last_index == null or last_index == NAN:
		print("rip")
		return
	
	var last_spawn = [AutoLoad.spawnable_locations[0]]
	
	for i in range(10):
		rng.randomize()
		var index = rng.randi_range(0, last_index)
		var spawn_position = AutoLoad.spawnable_locations[index]
		for j in last_spawn:
			if j.x - spawn_position.x > 400:
#				print("true")
				mobs_spawned += 1
				spawn_mob(spawn_position)
				break
		if abs(old_mob_count - mobs_spawned) <= 0:
			i -= 1
		else:
			old_mob_count = mobs_spawned
#	$Camera2D.set_global_position(spawn_position)
	
func spawn_mob(location):
	var mob = mob_scene.instance()
	call_deferred("add_child", mob)
	mob.set_global_position(location)
