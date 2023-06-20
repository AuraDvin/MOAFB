extends Node2D

onready var player = $AnimatedSprite
onready var camera = $Camera2D

func _ready():
	camera.current = true
	player.play("default")
