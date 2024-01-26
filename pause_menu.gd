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
