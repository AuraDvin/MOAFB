extends KinematicBody2D

const UP = Vector2(0, -1)
const GRAVITY = 30
const MAXFALLSPD = 600
const MAXSPD = 375
const ACCEL = 4

var motion  =  Vector2()
var player_location = Vector2()
var is_moving_left = true
var location_check = 0

onready var level_name = get_tree().get_current_scene().get_name()
onready var player = get_tree().get_root().get_node_or_null("./" + level_name + "/Player")

func _ready():
	$Sprite.play("default")



func _process(delta):
#	location_check += delta
#if location_check > 1000:
	find_player(delta)     # sets is_going_left first
#location_check = 0
	detect_ledge(delta)    # overwrites is_going_left if necessary
	move_enemy(delta)
	

func move_enemy(_delta):
	
	motion.x += -ACCEL if is_moving_left else ACCEL
	
	if abs(motion.x) > MAXSPD:
		motion.x = sign(motion.x) * MAXSPD
	
	motion.y += GRAVITY if not is_on_floor() else 1
	
	if motion.y > MAXFALLSPD:
		motion.y = MAXFALLSPD
		
	motion = move_and_slide(motion, UP, true)

func find_player(_delta):
	if player == null: # If there is no player in the scene dont do anything
		return
	
	player_location = player.position
#	if player_location != null:
#		print (player_location)
#	is_moving_left = player_location.x <= position.x 
	var before = is_moving_left
	
	var distance = position.distance_to(player_location)
	if distance > 700:
		return
	
	is_moving_left = player_location.x <= position.x
	
	if is_moving_left != before:   
		print("Changed directions")
		scale.x = -scale.x


func detect_ledge(_delta):
	if not $edge.is_colliding() and is_on_floor():
		is_moving_left = !is_moving_left
#		print("About to fall off")
		scale.x = -scale.x
		motion.x *= 0.4


func _on_playerCollision_body_entered(body):
	pass
#	print("Body entered")
#	print(body)

func hit():
	print("Imagine I hit something")
	$playerHitter.monitoring = true
	
func end_hit():
	print("ok no more hitting")
	$playerHitter.monitoring = false



