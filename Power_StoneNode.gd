extends Control

@export var selectable : bool
@export var power_stone : PowerStone


func _ready():
	selectable = power_stone.selectable
	$TextureRect.texture = power_stone.text

func is_selectable():
	return selectable
