extends ProgressBar

const STEP = 1

export (int) var health = 0

func _ready():
	pass

func _process(delta):
	if health == self.value:
		return
	
	if health > self.value:
		self.value += STEP * delta * 100
	elif health < self.value: 
		self.value -= STEP * delta * 100
	
	var health_value_delta = abs(health - self.value)
	if health_value_delta <= 1:
		self.value = health
	

func update_health(health_now):
	health_now = clamp(health_now, 0, 100)
	health = health_now


func _on_Player_health_change(newHealth):
	update_health(newHealth)
