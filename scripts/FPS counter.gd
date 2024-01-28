extends Label

func _process(_delta: float) -> void:
	var hp = get_parent().get_parent().hp
	var s = str(Engine.get_frames_per_second()) + " FPS\n"
	if hp > 0:
		s +=  "Hp: " + str(int(hp))
	set_text(s)
