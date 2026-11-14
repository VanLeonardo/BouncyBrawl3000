extends CanvasLayer
## Pause menu - resume or return to title

func _ready() -> void:
	$Panel/VBoxContainer/ResumeButton.pressed.connect(_on_resume)
	$Panel/VBoxContainer/TitleButton.pressed.connect(_on_title)
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("p1_pause"):
		toggle_pause()

func toggle_pause() -> void:
	if visible:
		_on_resume()
	else:
		show_pause()

func show_pause() -> void:
	visible = true
	get_tree().paused = true
	GameManager.pause_fight()

func _on_resume() -> void:
	visible = false
	get_tree().paused = false
	GameManager.resume_fight()

func _on_title() -> void:
	visible = false
	get_tree().paused = false
	GameManager.fight_state = GameManager.FightState.NONE
	get_tree().change_scene_to_file("res://scenes/ui/title_screen.tscn")
