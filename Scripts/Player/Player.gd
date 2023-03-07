extends KinematicBody2D

signal mine_block(x, y)

const UP:Vector2 = Vector2(0, -1)
const GRAVITY:int = 30
const MAXFALLSPD:int = 600
const MAXSPD:int = 400
const JUMPFORCE:int = 800
const ACCEL:int = 40
const SHOOT_RADIUS:float = 100.00

var motion:Vector2 = Vector2()
var canShoot:bool = true

#onready var slope_ray_right = get_node("slopeRayRight")
#onready var slope_ray_left = get_node("slopeRayLeft")
onready var down_ray = get_node("downRay")
onready var sprite = get_node("Sprite")
onready var animationPlayer = get_node("AnimationPlayer")
onready var bullet =  preload ("res://scripts/bullet/Bullet.tscn")

func _physics_process(_delta):
	if ( ! is_on_floor()):
		motion.y += GRAVITY
		if (motion.y > MAXFALLSPD):
			motion.y = MAXFALLSPD
	else :
		motion.y = 0

	motion.x = clamp(motion.x, -MAXSPD, MAXSPD)

	if (Input.is_action_pressed("move_left")):
		motion.x -= ACCEL
		animationPlayer.play("Run")
	elif (Input.is_action_pressed("move_right")):
		motion.x += ACCEL
		animationPlayer.play("Run")
	else :
		motion.x = lerp(motion.x, 0, 0.2)
		animationPlayer.play("Idle")

	handleFlip(int(motion.x))

	if Input.is_action_just_pressed("move_up") and down_ray.is_colliding():
		jump()
		# AutoLoad.auraLog( 'Jumped for some reason' )
		# AutoLoad.auraLog(down_ray.is_colliding())

	if Input.is_action_just_pressed("mine") and $miner.is_colliding():
		# var point = $miner.get_colliding_point().world_to_map(get_collision_point())
		var point = $miner.get_collision_point()
		# point = point.world_to_map()
		if $miner.get_collider() != null:
			# $miner.get_collider().free()'
			AutoLoad.auraLog(point)
			AutoLoad.auraLog('moment')
			emit_signal("mine_block", point.x, point.y)
			pass

	if Input.is_action_just_released("move_up"):
		jumpCut()

	#var snap = Vector2.DOWN
	#motion = move_and_slide_with_snap(motion, snap, UP, 1, 1)
	checkFallingAnim(motion.y)
	motion = move_and_slide(motion, UP, true)
	


func _input(event) -> void:
	# only check for mouse events
	if event is InputEventMouseMotion:
		$miner.look_at(get_global_mouse_position())
		$miner.rotate(-PI * 0.5)
		# print("mouse moved", event)
		pass

	#
	
	if not event is InputEventMouseButton or not canShoot or event.get_button_index() != 1:
		return

	var mouse_pos = get_global_mouse_position()
	var distance = global_transform.origin.distance_to(mouse_pos)
	var mouse_dir = (mouse_pos - global_transform.origin).normalized()
	var scene_root = get_tree().get_root()

	if distance > SHOOT_RADIUS:
		mouse_pos = global_transform.origin + (mouse_dir * SHOOT_RADIUS)

	if canShoot:
		canShoot = false
		get_node("shootDelay").start(0)

	var bullet_instance = bullet.instance()
	bullet_instance.init(global_transform.origin)
	scene_root.add_child(bullet_instance)
	bullet_instance.global_transform.origin = mouse_pos
func jump():
	motion.y = -JUMPFORCE

func jumpCut():
	if motion.y < -100:
		motion.y = -100

func handleFlip(x:int) -> void:
	if x == 0:
		return
	sprite.flip_h = x < 0


func checkFallingAnim(y:float):
	if y == 0:
		return 0
	if y > 0:
		if ( not down_ray.is_colliding()):
			animationPlayer.play("Fall")
		return 1
	animationPlayer.play("Jump")
	return 0

func _on_shootDelay_timeout():
	canShoot = true

