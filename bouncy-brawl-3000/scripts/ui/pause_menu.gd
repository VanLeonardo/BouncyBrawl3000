extends CanvasLayer
## Pause menu - resume or return to title with gamepad controller navigation.

@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var title_button: Button = $Panel/VBoxContainer/TitleButton

func _ready() -> void:
	resume_button.pressed.connect(_on_resume)
	title_button.pressed.connect(_on_title)
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("p1_pause") or event.is_action_pressed("p2_pause") or event.is_action_pressed("ui_pause"):
		toggle_pause()
	elif visible and event.is_action_pressed("ui_cancel"):
		_on_resume()

func toggle_pause() -> void:
	if visible:
		_on_resume()
	else:
		show_pause()

func show_pause() -> void:
	visible = true
	get_tree().paused = true
	GameManager.pause_fight()
	resume_button.grab_focus()

func _on_resume() -> void:
	visible = false
	get_tree().paused = false
	GameManager.resume_fight()

func _on_title() -> void:
	visible = false
	get_tree().paused = false
	GameManager.fight_state = GameManager.FightState.NONE
	get_tree().change_scene_to_file("res://scenes/ui/title_screen.tscn")
