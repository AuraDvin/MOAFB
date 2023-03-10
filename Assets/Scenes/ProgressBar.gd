extends ProgressBar

const STEP = 1

var health = 0

func _ready():
	pass

func _process(delta):
#	print('Health ', health)
#	print('Slider ', self.value)
	if health == self.value:
		return
	
	if health > self.value:
		self.value += STEP * delta * 100
		
	if health < self.value: 
		self.value -= STEP * delta * 100
			
	pass
	if Input.is_key_pressed(KEY_D):
		self.value += 1 * delta * 100
	if Input.is_key_pressed(KEY_A):
		self.value -= 1 * delta * 100

func update_health_value(new_value : int):
	self.value = new_value


func _on_Button_pressed():
#	print('Button 1 pressed')
	health -= 10
	health = clamp(health, 0, 100)
#	update_health_value(health)


func _on_Button2_pressed():
#	print('Button 2 pressed')
	health += 10
	health = clamp(health, 0, 100)
