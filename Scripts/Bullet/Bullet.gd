extends RigidBody2D

const radius: float = 100.00
const delay: float = 2.00

var m_direction = Vector2(0, 0)
var player_position: Vector2
var player_object

func _ready() -> void:
	pass

func _process(delta) -> void:
	var direction = (self.get_global_position() - m_direction) * 100
	self.add_central_force(direction * delta)

func _on_Timer_timeout() -> void:
	queue_free()

func init(direction: Vector2) -> void: 
	m_direction = direction
