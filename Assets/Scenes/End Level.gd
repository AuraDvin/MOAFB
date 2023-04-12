extends Node2D

signal finished_writing

var gold
var gold_num
var counter = 0
var time = 0
var done = false
var num_of_flashes = 14

onready var hbox = $CanvasLayer/CenterContainer/HBoxContainer
onready var gold_label = $CanvasLayer/CenterContainer/HBoxContainer/Gold_Collected
onready var back_button = $CanvasLayer/Back_to_main
onready var timer = $Timer
onready var margin_container = $CanvasLayer/CenterContainer

func _ready():
	gold = str(AutoLoad.getGold())
	gold_num = AutoLoad.getGold()
	

func _process(delta):
	time += delta * 1000
	if time < 20:
		return
	time = 0
	gold_label.text = str(counter)
	
	margin_container.add_constant_override("margin_right", -(get_viewport().size.x * 0.5 - hbox.rect_size.x * 0.5))
	
	if counter < gold_num:
		counter += 1
		return
	if not done:
		emit_signal("finished_writing")
		done = true
	back_button.visible = true
	set_process(false)

func _on_End_Level_finished_writing():
	timer.start()

func _on_Timer_timeout():
	hbox.visible = not hbox.visible 
	num_of_flashes -= 1 
	if num_of_flashes < 0:
		hbox.visible = true
		return
	timer.start()



func _on_Back_to_main_pressed():
	get_tree().change_scene("res://Assets/Scenes/Main_Menu_scene.tscn")
