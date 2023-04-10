extends Node2D

onready var player = $AnimatedSprite

func _ready():
	player.play("default")
