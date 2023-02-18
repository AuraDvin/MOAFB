extends RigidBody2D


const radius: float = 100.00
const delay: float = 2.00

var m_direction = Vector2(0, 0)
var player_position: Vector2
var player_object
# var bullet


# func _input(event) -> void:
# 	if !(event is InputEventMouseButton):
# 		return
# 	var mouse_pos = get_global_mouse_position()
# #	var player_pos = player.global_transform.origin 
# 	var distance = player_position.distance_to(mouse_pos) 
# 	var mouse_dir = (mouse_pos - player_position).normalized()
# 	var scene_root = get_tree().get_root()
# 	if distance > radius:
# 		mouse_pos = player_position + (mouse_dir * radius)
# 	if (player_object.canShoot): 
# 		player_object.canShoot = false
# 		player_object.get_node("shootDelay").start(0)
		

#		player.get_node(\"shootDelay\").start(0)
#		var bulletObject = self.instance()
#		bulletObject.init(player_position)
#		add_child(bulletObject)
#		bulletObject.global_transform.origin = mouse_pos

func _ready() -> void:
	pass
#	player_object = get_parent()
#	print(player_object)
#	player_position = player_object.global_position

func _process(delta) -> void:
	var direction = (self.get_global_position() - m_direction) * 100
#	var direction = (self.get_global_position() - player_position) * 100
	self.add_central_force(direction * delta)

func _on_Timer_timeout() -> void:
	queue_free()


func init(direction: Vector2) -> void: 
	m_direction = direction
