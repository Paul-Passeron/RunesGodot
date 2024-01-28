extends Node3D

var is_open = false

@onready var area_3d = $Area3D
@onready var collision_shape_3d = $MeshInstance3D/StaticBody3D/CollisionShape3D
@onready var animation_player = $AnimationPlayer

var can_interact = true

func _ready():

	animation_player.connect("animation_finished", finished)
	collision_shape_3d.disabled = false
	area_3d.get_children(true)[0].disabled = false
	

func finished(name_anim):
	if name_anim == "open":
		can_interact = true
		collision_shape_3d.disabled = false
		area_3d.get_children(true)[0].disabled = false
		

		

func interact():
	if can_interact:
		can_interact = false
		area_3d.get_children(true)[0].disabled = true
		collision_shape_3d.disabled = true
		if is_open:
			animation_player.play_backwards("open")
		else:
			animation_player.play("open")
		is_open = not is_open
