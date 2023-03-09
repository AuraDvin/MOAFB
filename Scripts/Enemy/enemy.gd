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
var should_move = true
var time_when_stopped = 0

onready var level_name = get_tree().get_current_scene().get_name()
onready var player = get_tree().get_root().get_node_or_null("./" + level_name + "/Player")
onready var stop_timer = $stopMoving

func _ready():
#	$Sprite.play("default")
	# print("moment")
	$AnimatedSprite.play("default")

func _process(delta):
	var now = Time.get_ticks_msec()
	
	find_player(delta)     # sets is_going_left first
	
	if not should_move:
		$AnimatedSprite.play("default")
#		print("cant move lol ", Time.get_ticks_msec())
		return
	if now - time_when_stopped < 42:
		return
	detect_ledge(delta)    # overwrites is_going_left if necessary
	move_enemy(delta)      # uhu
	

func move_enemy(_delta):
	
	motion.x += -ACCEL if is_moving_left else ACCEL
	
	if abs(motion.x) > MAXSPD:
		motion.x = sign(motion.x) * MAXSPD
	
	motion.y += GRAVITY if not is_on_floor() else 1
	
	if motion.y > MAXFALLSPD:
		motion.y = MAXFALLSPD
		
	motion = move_and_slide(motion, UP, true)
	$AnimatedSprite.play("walk")

func find_player(_delta):
	if player == null: # If there is no player in the scene dont do anything
		return
		
	var before = is_moving_left
	player_location = player.position
	var distance = position.distance_to(player_location)

	if distance > 700:
		return
	is_moving_left = player_location.x <= position.x
	
	if is_moving_left != before:   
		# print("Changed directions")
		scale.x = -scale.x

func detect_ledge(_delta):
	
	if not $edge.is_colliding() and is_on_floor():
#		scale.x = -scale.x
		# print("started timer")
		if stop_timer.time_left == 0:
			stop_timer.start()
			should_move = false

func hit():
	# print("Imagine I hit something")
	$AnimatedSprite.play("Attack")
	$playerHitter.monitoring = true
	
func end_hit():
	# print("ok no more hitting")
	$playerHitter.monitoring = false

func _on_playerCollision_body_entered(body):
	print(body)
	hit()
	pass
#	print("Body entered", body)

func _on_stopMoving_timeout():
	scale.x = -scale.x
	is_moving_left = !is_moving_left
	motion.x *= 0.4
	should_move = true
	time_when_stopped = Time.get_ticks_msec()
#	print("About to fall off")
