extends RigidBody2D

var m_direction = Vector2(0, 0)

func _ready():	
	pass

func _process(delta):
	var direction = (self.get_global_position() - m_direction) * 100
	self.add_central_force(direction * delta)

func _on_Timer_timeout():
	queue_free()


func init(direction: Vector2) -> void: 
	m_direction = direction
