extends KinematicBody2D

signal mine_block(x, y, direction)
signal health_change(newHealth)
signal move_smart_cursor(position, normal)
signal cursor_visibility(yes)
signal left_level
signal deal_damage_to_enemy(value)

const UP: Vector2 = Vector2(0, -1)
const GRAVITY: int = 30
const MAXFALLSPD: int = 600
const MAXSPD: int = 400
const JUMPFORCE: int = 800
const ACCEL: int = 40
const SHOOT_RADIUS: float = 100.00

var motion: Vector2 = Vector2()
var canShoot: bool = true
var health = 100
var minerPoint = Vector2()
var minerNormal = Vector2()
var can_leave = false
var can_hit = true
# debug
#var debug_sprite = preload("res://icon.png")

onready var down_ray = get_node("downRay")
onready var bullet = preload("res://scripts/bullet/Bullet.tscn")
onready var mySprite = get_node("AnimatedSprite")
onready var block_mining_timer = $MineBlock
onready var smart_cursor_UI_label = $Camera2D/UI/HUD/smart_cursor_position
onready var gold_counter_label = $Camera2D/UI/HUD/Gold_HUD/Gold_inventory
onready var hit_timer = $HitMoment
onready var hit_area = $hitArea


func _ready():
	for member in get_tree().get_nodes_in_group("Enemy"):
#		print_debug(member)
		member.connect("enemy_died", self, "_on_get_kill")
		
	mySprite.play("default")
	emit_signal("health_change", health)
	var _returns_from_connect = AutoLoad.connect("addedGold", self, "_on_Gold_updated")

func _physics_process(_delta):
	if not is_on_floor():
		motion.y += GRAVITY
		if motion.y > MAXFALLSPD:
			motion.y = MAXFALLSPD
	else:
		motion.y = 0

	motion.x = clamp(motion.x, -MAXSPD, MAXSPD)

	if Input.is_action_pressed("move_left"):
		motion.x -= ACCEL
		if not (mySprite.animation == "mineGold" or  mySprite.animation == "mineStone"):
			mySprite.play("run")
	elif Input.is_action_pressed("move_right"):
		motion.x += ACCEL
		if not (mySprite.animation == "mineGold" or  mySprite.animation == "mineStone"):
			mySprite.play("run")
	else:
		motion.x = lerp(motion.x, 0, 0.2)
		if not (mySprite.animation == "mineGold" or  mySprite.animation == "mineStone"):
			mySprite.play("default")
		

	handleFlip(int(motion.x))

	if Input.is_action_just_pressed("move_up") and down_ray.is_colliding():
		jump()

	if $miner.is_colliding() and $miner.get_collider().is_in_group('tilemap'):
		var tile_location = $miner.get_collision_point()
		var normal = $miner.get_collision_normal()
		
		if mySprite.animation != "mineStone":
			emit_signal("cursor_visibility", true)
			emit_signal("move_smart_cursor", tile_location, normal)
	elif mySprite.animation != "mineStone":
		emit_signal("cursor_visibility", false)
	if Input.is_action_just_pressed("action_mine"):
		hit_area.monitoring = true
		hit_area.visible = true
		mySprite.play("mineStone")
		if $miner.is_colliding() and $miner.get_collider().is_in_group('tilemap'):
			var point = $miner.get_collision_point()
			var normal = $miner.get_collision_normal()  # to pass for direction
			if $miner.get_collider() != null:
				block_mining_timer.start()
				minerPoint = Vector2(point.x, point.y)
				minerNormal = normal
	elif not Input.is_action_pressed("action_mine") and mySprite.animation != "run":
		mySprite.play("default")

	if not Input.is_action_pressed("action_mine"):
		hit_area.monitoring = false
		hit_area.visible = false
	
	if Input.is_action_just_released("move_up"):
		jumpCut()

	checkFallingAnim(motion.y)
	motion = move_and_slide(motion, UP, true)



func _input(event) -> void:
	if event is InputEventMouseMotion:
		$miner.look_at(get_global_mouse_position())
		$miner.rotate(-PI * 0.5)
	
#	if event is InputEventKey and not event.pressed:
#		if event.scancode == KEY_J:
#			takeDamage(10)
#		elif event.scancode == KEY_K:
#			takeDamage(-10)
#
#	if not event is InputEventMouseButton or not canShoot or event.get_button_index() != 1:
#		return
#	shootBullet()


func _unhandled_input(event):
	if not event is InputEventKey:
		return
	if not event.pressed and event.scancode == KEY_E and can_leave:
		emit_signal("left_level")
		queue_free()

func shootBullet():
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

func handleFlip(x: int) -> void:
	if x == 0:
		return
	mySprite.flip_h = x < 0

func checkFallingAnim(y: float):
	if y == 0:
		return 0
	if y > 0:
		if not down_ray.is_colliding():
			# Play falling animation
			pass
		return 1
	# Play jumping animation
	return 0

func takeDamage(value):
	health -= value
	health = clamp(health, 0, 100)
	emit_signal("health_change", health)
	if health <= 0:
		die_on_level()
	

func _on_shootDelay_timeout():
	canShoot = true

func _on_MineBlock_timeout():
	emit_signal("mine_block", minerPoint.x, minerPoint.y, minerNormal)

func _on_Door_near_door():
	can_leave = true

func _on_Door_not_near_door():
	can_leave = false
	
func _on_caveGenerator_new_world_position_of_smart_cursor(new_position_of_cursor):
	smart_cursor_UI_label.text = str(new_position_of_cursor)

func _on_Gold_updated(amount):
	gold_counter_label.text = str(amount)


func _on_enemy_dealDamage(value):
	takeDamage(value)

func die_on_level():
	emit_signal("left_level")
	queue_free()


func _on_HitMoment_timeout():
	can_hit = true

func _on_hitArea_body_entered(body):
	if not body.is_in_group("Enemy") or not can_hit:
		return
#	print("opa moment :D")
#	body.take_damage(50)
	emit_signal("deal_damage_to_enemy", 60)
	hit_timer.start()
	can_hit = false
	
func _on_get_kill():
	AutoLoad.addGold()
