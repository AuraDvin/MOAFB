extends ProgressBar


func _ready():
	pass

func _process(delta):
	if Input.is_key_pressed(KEY_D):
		self.value += 1 * delta * 100
	if Input.is_key_pressed(KEY_A):
		self.value -= 1 * delta * 100

func update_health_value(new_value : int):
	self.value = new_value
