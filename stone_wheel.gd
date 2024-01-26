extends Control

@export var selected = 0
var old_selected = 0

func _ready():
	old_selected = selected

func _process(_delta):
	$Container.selected = selected
	if selected != old_selected:
		$Container.place_buttons()
	old_selected = selected
