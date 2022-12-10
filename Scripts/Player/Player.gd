extends KinematicBody2D

const UP = Vector2(0, -1)
const GRAVITY = 30
const MAXFALLSPD = 600
const MAXSPD = 400
const JUMPFORCE = 800
const ACCEL = 40

var motion  =  Vector2()

onready var down_ray = get_node("downRay")
onready var slope_ray_right = get_node("slopeRayRight")
onready var slope_ray_left = get_node("slopeRayLeft")
onready var sprite = get_node("Sprite")
onready var animationPlayer = get_node("AnimationPlayer")


func jump():
	motion.y = -JUMPFORCE

func jumpCut():
	if (motion.y < -100):
		motion.y = -100

func _physics_process(_delta):
	if (!is_on_floor()):
		motion.y += GRAVITY
		if (motion.y > MAXFALLSPD):
			motion.y = MAXFALLSPD
	else:
		motion.y = 0
	
	motion.x = clamp(motion.x, -MAXSPD, MAXSPD)
	
	if (Input.is_action_pressed("ui_left")):
		motion.x -= ACCEL
		sprite.flip_h = true
		animationPlayer.play("Run")
	elif (Input.is_action_pressed("ui_right")):
		motion.x += ACCEL
		sprite.flip_h = false
		animationPlayer.play("Run")
	else:
		motion.x = lerp(motion.x, 0, 0.2)
		# motion.x = 0
		animationPlayer.play("Idle")
	
	if (Input.is_action_just_pressed("ui_accept") && is_on_floor()):
		jump()

	if (Input.is_action_just_released("ui_accept")):
		jumpCut()
	
	#* This can detec whether the player is colliding on the left/right
	# if (slope_ray_left.is_colliding() && motion.x < 0):
	# 	print('left slope')
	# elif (slope_ray_right.is_colliding() && motion.x > 0):
	# 	print('right slope')
	# motion = move_and_slide(motion, UP, 1, 1, PI/4)
	var snap = Vector2.DOWN
	# if (motion.y < 0):
	# 	snap = Vector2.ZERO
	motion = move_and_slide_with_snap(motion, snap, UP, 1, 1)
	
	if (motion.y > 0):
		if(!down_ray.is_colliding()):
			animationPlayer.play("Fall")
	elif (motion.y < 0):
		animationPlayer.play("Jump")
