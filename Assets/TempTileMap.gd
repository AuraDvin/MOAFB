extends TileMap

signal script_done


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_caveGenerator_finished_generating():
	emit_signal("script_done")
