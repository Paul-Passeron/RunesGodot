extends Control

@export var hp_perc = 100.0

var original_size = 0
func _ready():
	original_size = $ColorRect2.size.x

func _process(_delta):
	$ColorRect2.size.x = hp_perc / 100.0 * original_size

