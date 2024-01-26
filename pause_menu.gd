extends Control

func _on_quit_pressed():
	get_tree().quit()


func _on_restart_pressed():
	get_parent().get_parent().restart()
	resume()

func resume():
	Global.game_paused = false
	visible = false

func _on_resume_pressed():
	resume()


func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://start_menu.tscn")

