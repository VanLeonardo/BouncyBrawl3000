extends Control
## Title Screen with Play Campaign button

func _ready() -> void:
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	GameManager.current_fight = 0
	get_tree().change_scene_to_file("res://scenes/campaign/arena.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
