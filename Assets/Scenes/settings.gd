extends Control

onready var menu = $CanvasLayer/Menu
onready var busy_screen = $CanvasLayer/PressButtonScreen

const main_menu = "res://Assets/Scenes/Main_Menu_scene.tscn"
const settings_menu = "res://Assets/Scenes/settings.tscn"

var handle_input = false
var focused_action = null
var max_lenght = 0

var inputs = [
	"move_up",
	"move_left",
	"move_right",
	"action_mine",
	"action_Map"
]

func _ready():
#	for i in inputs:
#		if max_lenght < i.length():
#			max_lenght = i.length()
			
	for i in InputMap.get_actions():
		if inputs.has(i):
#			print(i)
			var object = HBoxContainer.new()
			var label = Label.new()
			var key = Label.new()
			var button = Button.new()
			
			key.text = char(InputMap.get_action_list(i)[0].scancode)
			if key.text == " ":
				key.text = "Space"
			key.rect_min_size.x = 70
			key.rect_min_size.y = 24
			
			label.text = i.replace("action", "").replace("_", " ").capitalize()
			label.rect_min_size.x = 122
			label.rect_min_size.y = 24
			
			button.text = "Change"
			button.rect_size.x = 122
			button.rect_size.y = 24
			button.connect("pressed", self, "test", [i, key.text, button])
			
			object.add_child(label)
			object.add_child(key)
			object.add_child(button)
			object.add_constant_override("separation", 100)
			
			object.name = i
			
			key.name = i + "_key"
			label.name = i + "_label"
			button.name = i + "_button"
			menu.add_child(object)
	
	for i in menu.get_children():
		menu.move_child(i, inputs.find(i.name))

func test(_text, keycode, button):
	button.release_focus()
	focused_action = button.get_parent()
#	print(text, " ", keycode)
	busy_screen.visible = true
	handle_input = true


func _input(event):
	if not event is InputEventKey or not handle_input:
		return
	
#	print("moment")
	var action = focused_action.name if not focused_action == null else ""
	
#	print(action)
	
	var character = event.scancode
	if (character < KEY_A or character > KEY_Z) and (character != KEY_SPACE):
#		print_debug(character, " ", char(character))
		if character == KEY_ESCAPE:
			handle_input = false
			busy_screen.visible = false
#			print("no action")
#			print()
			focused_action = null
			return
		else:
			character = "invalid"
	else:
		if character != KEY_SPACE:
			character = char(character)
		else:
			character = "Space"
	
#	print(character)
#	print()
	
	if character == "invalid":
#		print_debug("character is invalid")
		return

	for i in focused_action.get_children():
		var object_thing = i.name.get_slice("_", 2)
		if not object_thing == "key":
			continue
#		print(object_thing, " from: ", i.text, " to: ", character)
		
		if i.text == character:
			return
			
		var string = i.name.get_slice("_", 0) + "_" + i.name.get_slice("_", 1)
		var ev = InputEventKey.new()
		ev.pressed = true
		ev.set_scancode(event.scancode)
		
#		print_debug(string)
		
		InputMap.action_erase_events(string)
		InputMap.action_add_event(string, ev)
		
#		print_debug("reload")
		get_tree().change_scene(settings_menu)
		
	handle_input = false
	busy_screen.visible = false

func _on_Return_pressed():
	get_tree().change_scene(main_menu)
