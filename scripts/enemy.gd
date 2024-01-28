extends CharacterBody3D

@export var hp = 100
var gravity = 20
@onready var animation_player = $AnimationPlayer
@onready var sprite_3d = $Sprite3D
@onready var dead_sprite = $Dead
@onready var collision_shape_3d = $CollisionShape3D
@onready var hurt_sound = $HurtSound
@onready var area_3d = $Area3D
@export var damage_points = 20
const good_dist_player = 2.4
var can_hit = true
var dead = false
#@export var cooldown_time = 0.5
@export var max_wait_time = 5

var angle_max = 1.0
var speed_random = 0.3
var speed = 22
var min_distance_see = 50
var found_player = false
var wait_before_attack_timer: Timer = null
var player = null

var offset = 0

func _init():
	wait_before_attack_timer = Timer.new()
	wait_before_attack_timer.connect("timeout", timeout)
	wait_before_attack_timer.one_shot = true
	add_child(wait_before_attack_timer)
	offset = 2 * PI * randf()



func kill():

	dead_sprite.visible = true
	sprite_3d.visible = false
	collision_shape_3d.disabled = true
	dead = true
	hurt_sound.play()

	
func _process(delta):
	if Global.game_paused:
		return
	if dead:
		return
	if not is_on_floor():
		velocity.y -= gravity * delta
	var entities = get_tree().get_nodes_in_group("player")
	for entity in entities:
		if entity.name == "Player":
			player = entity
			break
	var good_dist = false
	if(player != null):
		var vec = player.global_position
		var pos = Vector2(global_position.x, global_position.z)
		var d = pos.distance_to(Vector2(vec.x, vec.z)) 
		if (d < min_distance_see or found_player) and d > good_dist_player:
			found_player = true
			var motion = pos.direction_to(Vector2(vec.x, vec.z))
			var s =  (1 - 2 * speed_random + speed_random * randf())
			velocity.x = motion.x * speed * s
			velocity.z = motion.y * speed * s
			look_at(player.global_transform.origin, Vector3.UP)

		else:
			
			velocity.x = 0
			velocity.z = 0
		good_dist = get_good_dist()
		var t = Time.get_ticks_msec() / 1000.0
		var angle = cos(2*PI*t + offset)*angle_max
		var velo = Vector3(velocity.x, velocity.z, 0)
		velo = velo.rotated(Vector3.UP, angle)
		velocity.x = velo.x
		velocity.z = velo.y
		move_and_slide()
		
		
		
		if not animation_player.is_playing():
			can_hit = true
		# hitting player code
		if can_hit_player() and good_dist and wait_before_attack_timer.is_stopped():
			can_hit = false
			wait_before_attack_timer.start(max_wait_time*randf_range(0.33, 1))

func timeout():
	hit()
	can_hit = true
func get_good_dist():
	var bo = false
	if dead:
		return

	var b = area_3d.get_overlapping_bodies()
	for e in b:
		if e.name == "Player":
			bo = true
			break
	return bo
func hit():
	if dead:
		return
	if get_good_dist() and player != null:
		player.damage(damage_points)
	animation_player.play("hit_player")
	$PunchSound.play()

func can_hit_player():
	if dead:
		return
	var cond = false
	var entities = area_3d.get_overlapping_bodies()
	for entity in entities:
		if entity.name == "Player":
			cond = true
			break
	return can_hit and cond and is_on_floor()
	

func damage_from_player(val):
	
	found_player = true
	animation_player.play("hit")
	hp -= val
	if(hp <= 0):
		kill()


