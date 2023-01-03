extends KinematicBody2D

const UP = Vector2(0, -1)
const GRAVITY = 30
const MAXFALLSPD = 600
const MAXSPD = 400
const JUMPFORCE = 800
const ACCEL = 40

var motion  =  Vector2()
var canShoot = true

onready var down_ray = get_node("downRay")
onready var slope_ray_right = get_node("slopeRayRight")
onready var slope_ray_left = get_node("slopeRayLeft")
onready var sprite = get_node("Sprite")
onready var animationPlayer = get_node("AnimationPlayer")
onready var bullet = preload("res://scripts/bullet/Bullet.tscn")


func jump():
	motion.y = -JUMPFORCE

func jumpCut():
	if (motion.y < -100):
		motion.y = -100

func handleFlip(x:int) -> void:
	if (x == 0):
		return
	sprite.flip_h = (x < 0)

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
		animationPlayer.play("Run")
	elif (Input.is_action_pressed("ui_right")):
		motion.x += ACCEL
		animationPlayer.play("Run")
	else:
		motion.x = lerp(motion.x, 0, 0.2)
		animationPlayer.play("Idle")
	
	handleFlip(motion.x)
	
	if (Input.is_action_just_pressed("ui_accept") && down_ray.is_colliding()):
		jump()
	
	if (Input.is_action_just_released("ui_accept")):
		jumpCut()
	
	#var snap = Vector2.DOWN
	#motion = move_and_slide_with_snap(motion, snap, UP, 1, 1)
	motion = move_and_slide(motion, UP, true)
	checkFallingAnim(motion.y)

func checkFallingAnim(y:int):
	if (y == 0):
		return 0
	if (y > 0):
		if(!down_ray.is_colliding()):
			animationPlayer.play("Fall")
		return 1
	animationPlayer.play("Jump")
	return 0




func _on_shootDelay_timeout():
	print("ready")
	canShoot = true
