extends Control


func _on_play_pressed():
	get_tree().change_scene_to_file("res://world.tscn")
	Global.game_paused = false


func _on_quit_pressed():
	get_tree().quit()
	
