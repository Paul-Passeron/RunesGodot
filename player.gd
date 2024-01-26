extends CharacterBody3D

@onready var area_3d = $Area3D
@onready var pause_menu = $"CanvasLayer/Pause Menu"
@onready var interact_dialog = $CanvasLayer/Interact_dialog
@onready var hitmarker_sound = $HitmarkerSound
@onready var camera_3d = $Camera3D
@onready var ray_cast_3d = $Camera3D/RayCast3D
@onready var animation_player = $Camera3D/gun/AnimationPlayer
@onready var shoot_sound = $ShootSound

var crouch = false

const SPEED = 20
const JOY_SENS_H = 500.0
const JOY_SENS_V = 300.0
var run_speed = 40
const MOUSE_SENS = 0.3
const JUMP_VELOCITY = 20
const DOUBLE_JUMP_VELOCITY = 30
var gravity = 60
var can_shoot = true
var dead = false
var jump_dir = Vector2(0, 0)
var is_running = false
var is_controller = false
var damage_points = 25
var scoping = false
var fov_scope = 30.0
var fov_no_scope = 75.0
var can_interact = false
@onready var gun = $Camera3D/gun
var punch_radius = 4
@onready var fist = $Camera3D/fist

@export var mel_weap = false

@export var hp = 100

var standing_pos
var crouch_pos

var n_stones

var double_jump_time = 0.1
var can_double_jump = false
var double_jump_timer = null
var has_double_jumped = false

@onready var stone_wheel = $CanvasLayer/StoneWheel

# Dash
# Make sure to have a stone that "reloads" itself while dash cooldown 
var can_dash = true
var dash_timer : Timer = null
var is_dashing = false
var dash_cooldown = 2
var dash_speed = 150
var dash_time = 0.2

func dash_timeout():
	if is_dashing:
		is_dashing = false
		can_dash = false
		dash_timer.start(dash_cooldown)
	else:
		can_dash = true




func get_scope_mult():
	if scoping:
		return fov_scope / fov_no_scope
	else:
		return 1

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$CanvasLayer/DeathScreen/Panel/Button.button_up.connect(restart)
	animation_player.play("run", -1, 1000);
	$Camera3D/MuzzleFlash.set_visible(false)
	is_controller = len(Input.get_connected_joypads()) > 0
	interact_dialog.visible = false
	if mel_weap:
		gun.visible = false
		fist.visible = true
	else:
		gun.visible = true
		fist.visible = false
	standing_pos = camera_3d.position
	crouch_pos = standing_pos - 0.7 * Vector3.UP
	
	double_jump_timer = Timer.new()
	double_jump_timer.connect("timeout", on_double_jump_timer_timeout)
	double_jump_timer.one_shot = true
	add_child(double_jump_timer)
	
	
	dash_timer = Timer.new()
	dash_timer.connect("timeout", dash_timeout)
	dash_timer.one_shot = true
	add_child(dash_timer)
	
func _input(event):
	if Global.game_paused:
		return
	var m = get_scope_mult()
	if dead:
		return
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * MOUSE_SENS *m
		camera_3d.rotation_degrees.x -= event.relative.y * MOUSE_SENS*m
		camera_3d.rotation_degrees.x = clamp(camera_3d.rotation_degrees.x, -90, 30)
	if Input.is_action_pressed("inc_stone"):
		stone_wheel.selected -= 1
	if Input.is_action_pressed("dec_stone"):
		stone_wheel.selected += 1

func _physics_process(delta):
	$CanvasLayer/LifeBar.hp_perc = hp

	if Global.game_paused:
		return
	if dead:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
		
	if Input.is_action_just_pressed("exit"):
		pause_menu.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		Global.game_paused = not Global.game_paused
	if Global.game_paused:
		pause_menu.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	if Input.is_action_just_pressed("restart"):
		restart()
	
	if dead:
		return
		
	if Input.is_action_just_pressed("dash"):
		if can_dash:
			is_dashing = true
			dash_timer.start(dash_time)
			can_dash = false

	var interactables = area_3d.get_overlapping_areas()
	can_interact = len(interactables) > 0	
	interact_dialog.visible = can_interact
	if Input.is_action_just_pressed("change"):
		
		mel_weap = not mel_weap
	
		gun.visible = not gun.visible
		fist.visible = not fist.visible


	if Input.is_action_just_pressed("interact") and can_interact:
		var interactable = interactables[0].get_parent()
		if interactable.has_method("interact"):
			interactable.interact()
	
	if Input.is_action_just_pressed("shoot"):
		if not mel_weap:
			shoot()
		else:
			punch()
	if Input.is_action_pressed("scope") and not mel_weap:
		scoping = true
		camera_3d.fov = fov_scope
	else:
		scoping = false
		camera_3d.fov = fov_no_scope
		
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var m = get_scope_mult()
		
	if InputEventJoypadMotion:
		rotation_degrees.y += Input.get_action_strength("look_left") * JOY_SENS_H * delta *m
		rotation_degrees.y -= Input.get_action_strength("look_right") * JOY_SENS_H * delta *m
		camera_3d.rotation_degrees.x += Input.get_action_strength("look_up") * JOY_SENS_V * delta *m
		camera_3d.rotation_degrees.x -= Input.get_action_strength("look_down") * JOY_SENS_V * delta *m
		camera_3d.rotation_degrees.x = clamp(camera_3d.rotation_degrees.x, -90, 30)

	is_running =( is_running and not is_on_floor()) or Input.is_action_pressed("run")
	if is_running and animation_player.get_assigned_animation() == "run":
		animation_player.play("run", -1, 1)
	


	var input_dir = Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# Handle jump.
	if is_on_floor():
		if not is_dashing:
			jump_dir = direction
		else:
			direction = jump_dir			
		if Input.is_action_just_pressed("move_jump") :
			velocity.y = JUMP_VELOCITY
			double_jump_timer.start(double_jump_time)
		has_double_jumped = false
	else:
		if Input.is_action_just_pressed("move_jump")and not has_double_jumped:
			if can_double_jump:
				can_double_jump = false
				has_double_jumped = true
				velocity.y = DOUBLE_JUMP_VELOCITY
				jump_dir = direction
			
		else:	
			direction = jump_dir
		
	
	
	if (crouch and is_zone_crouch_only()) or (Input.is_action_pressed("crouch")  and is_on_floor()):
		crouch= true
		camera_3d.position = crouch_pos
		$CollisionShape3D2.disabled = true
	else:
		crouch = false
		camera_3d.position = standing_pos
		$CollisionShape3D2.disabled = false
		

		
		
	var speed = SPEED
	if is_running:
		speed = run_speed
	if is_dashing:
		speed = dash_speed
	if direction:
		if not animation_player.is_playing():
			animation_player.play("run", -1, 0.5)
		
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0.1, speed)
		velocity.z = move_toward(velocity.z, 0.1, speed)

	#if is_on_floor():
		#velocity = velocity.rotated(Vector3.RIGHT, get_floor_angle(Vector3.UP))
		#
	velocity.y -= gravity * delta
	
	move_and_slide()


func restart():
	get_tree().reload_current_scene()

func punch():
	if !can_shoot:
		return
	can_shoot = false
	animation_player.play("punch")
	if ray_cast_3d.is_colliding() and ray_cast_3d.get_collider().has_method("damage_from_player"):
		var p = ray_cast_3d.get_collider().global_position
		if global_position.distance_to(p) <= punch_radius:
			ray_cast_3d.get_collider().damage_from_player(damage_points)
			hitmarker_sound.play()
		
func shoot():
	if !can_shoot:
		return
	can_shoot = false
	animation_player.play("shoot")
	shoot_sound.play()
	if ray_cast_3d.is_colliding() and ray_cast_3d.get_collider().has_method("damage_from_player"):
		ray_cast_3d.get_collider().damage_from_player(damage_points)
		hitmarker_sound.play()
		

func damage(val):

	hp -= val
	if hp <= 0:
		kill()

func kill():
	dead = true
	$CanvasLayer/DeathScreen.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	

func is_zone_crouch_only():
	return false

func _on_animation_player_animation_finished(_anim_name):
	if _anim_name == "shoot" || _anim_name == "punch":
		can_shoot = true
		
		
func on_double_jump_timer_timeout():
	can_double_jump = true
