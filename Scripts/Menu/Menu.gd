extends Control

var last_mouse_position = Vector2.ZERO
var pointer_invisible_timestamp = 0

onready var timer_diss = $MouseDissappear

func _ready():
	$Main/Start_Button.grab_focus()

func _process(_delta):
	pass

func _input(event):
	var current_timestamp = Time.get_ticks_msec()
	var mouse_is_visible = Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE
	var global_mouse_pos = get_global_mouse_position()
	if event is InputEventKey and event.is_pressed() and mouse_is_visible:
		pointer_invisible_timestamp = current_timestamp
		last_mouse_position = global_mouse_pos if global_mouse_pos != Vector2.ZERO else last_mouse_position
		Input.warp_mouse_position(Vector2(0, 0))
		timer_diss.start() 
	
	var delta_time = current_timestamp - pointer_invisible_timestamp
	
	if delta_time < 100:
		return
	
	if event is InputEventMouseMotion and !mouse_is_visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Input.warp_mouse_position(last_mouse_position)
	
## 	EVENTS/TRIGGERS AND THINGS
func _on_Start_Button_pressed():
	print("pressed start")
	var moment = get_tree().change_scene("res://Assets/Scenes/cave.tscn")
	print(moment)

func _on_Quit_Button_pressed():
	get_tree().quit()

func _on_Options_Button_pressed():
	$Main.visible = false
	$Options.visible = true

func _on_BackToMenu_pressed():
	$Options.visible = false
	$Main.visible = true

func _on_Start_Button_mouse_entered():
	$Main/Start_Button.grab_focus()

func _on_Options_Button_mouse_entered():
	$Main/Options_Button.grab_focus()

func _on_Quit_Button_mouse_entered():
	$Main/Quit_Button.grab_focus()

func _on_MouseDissappear_timeout():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)