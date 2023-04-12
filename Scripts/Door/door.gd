extends Node

signal near_door
signal not_near_door

onready var door_sprite = $Sprite

var time_collection = 0
var frame = 0

func _ready():
	$AnimatedSprite.play("default")
	
func _process(delta):
	time_collection += delta * 1000
	
	if time_collection < 80:
		return
	
		
	time_collection = 0
	door_sprite.frame = frame
	frame += 1
	if frame > 7:
		frame = 0
	elif frame < 0:
		frame = 0
	




func _on_Area2D_body_entered(body):
	if not body.is_in_group("player"):
		return
#	print("Press E to leave game")
	$AnimatedSprite.visible = true
	emit_signal("near_door")


func _on_Area2D_body_exited(body):
	if not body.is_in_group("player"):
		return
	$AnimatedSprite.visible = false
	emit_signal("not_near_door")
