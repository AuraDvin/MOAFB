extends Control

#signal back_to_menu

func _on_Menu_go_to_options():
	$Settings/BackToMenu.grab_focus()
