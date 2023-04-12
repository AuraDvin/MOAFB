extends Node2D

func _ready():
	pass 

func _on_Player_left_level():
	get_tree().change_scene("res://Assets/Scenes/End Level.tscn")
