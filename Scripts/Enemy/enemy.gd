extends KinematicBody2D

signal dealDamage(value)

const UP = Vector2(0, -1)
const GRAVITY = 30
const MAXFALLSPD = 600
const MAXSPD = 375
const ACCEL = 4
const JUMPFORCE = -80

var motion  =  Vector2()
var player_location = Vector2()
var is_moving_left = true
var location_check = 0
var should_move = true
var time_when_stopped = 0
var damage = 10
var threshold = 250

onready var level_name = get_tree().get_current_scene().get_name()
onready var player = get_tree().get_root().get_node_or_null("./" + level_name + "/Player")
onready var stop_timer = $stopMoving
onready var navi = $NavigationAgent2D
#onready var navigation = get_tree().get_root().get_node("/root/tempScene/Navigation2d")

func _ready():
	pass
#	$AnimatedSprite.play("default")
	#TODO: Navigation setup 

func _physics_process(_delta):
	motion += applyGravity(_delta)
	move_to_target()
	
func applyGravity(_delta):
	var falling = Vector2()
	falling.y += GRAVITY * _delta if not is_on_floor() else 0
	if falling.y > MAXFALLSPD:
		falling.y = MAXFALLSPD
	return falling

func move_to_target():
	var direction = global_position.direction_to(navi.get_next_location())
	motion = direction * MAXSPD
	motion = move_and_slide(motion, UP)

func get_target_path(target_pos:Vector2):
	navi.set_target_location(target_pos)

func _process(_delta):
	if motion != Vector2.ZERO:
		$AnimatedSprite.play("walk")
	pass
	# return
# 	var now = Time.get_ticks_msec()
	
# 	find_player(delta)     # sets is_going_left first
	
# 	if not should_move:
# 		$AnimatedSprite.play("default")
# #		print("cant move lol ", Time.get_ticks_msec())
# 		return
# 	if now - time_when_stopped < 42:
# 		return
# #	detect_ledge(delta)    # overwrites is_going_left if necessary
# 	detect_wall()
# 	move_enemy(delta)      # uhu
	

func detect_wall():
	if $wall.is_colliding() and $wall.get_collider().is_in_group('tilemap'):
		jump()

func jump():
	motion.y = JUMPFORCE

func jump_cut():
	if motion.y < -30:
		motion.y += 50


func move_enemy(_delta):
	
	motion.x += -ACCEL if is_moving_left else ACCEL
	
	if abs(motion.x) > MAXSPD:
		motion.x = sign(motion.x) * MAXSPD
	
	motion.y += GRAVITY if not is_on_floor() else 0
	
	if motion.y > MAXFALLSPD:
		motion.y = MAXFALLSPD
		
	motion = move_and_slide(motion, UP, true)
	$AnimatedSprite.play("walk")

#TODO: make better
func find_player(_delta):
	if player == null:
		return
		
	var before = is_moving_left
	player_location = player.position
	var distance = position.distance_to(player_location)

	if distance > 700:
		return
		
	is_moving_left = player_location.x <= position.x 
	
	if player_location.y > position.y:
		jump()
	else:
		jump_cut()
		
	if is_moving_left != before:   
		scale.x = -scale.x

func detect_ledge(_delta):
	if not $edge.is_colliding() and is_on_floor():
		if stop_timer.time_left == 0:
			stop_timer.start()
			should_move = false

func hit():
	$AnimatedSprite.play("Attack")
	$playerCollision.call_deferred('set_monitoring', false)
	$hit.start()
	
func end_hit():
	$playerHitter.call_deffered('monitoring', false)

func _on_playerCollision_body_entered(body):
	if not body.is_in_group('player'):
		$playerCollision.call_deferred('monitoring', false)
		return
	
	hit()

func _on_stopMoving_timeout():
	scale.x = -scale.x
	is_moving_left = !is_moving_left
	motion.x *= 0.4
	should_move = true
	time_when_stopped = Time.get_ticks_msec()


func _on_hit_timeout() -> void:
	$playerHitter.call_deferred('monitoring', true)
	pass


func _on_playerHitter_body_entered(body):
	if not body.is_in_group('player'):
		return	
	emit_signal("dealDamage", damage)
	$playerHitter.call_deferred('monitoring', false)
	$playerCollision.call_deffered('monitoring', true)
