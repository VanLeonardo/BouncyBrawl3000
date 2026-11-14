extends Control
## Title Screen controller for Bouncy Brawl 3000.

@onready var play_button: Button = $MenuFrame/VBoxContainer/PlayButton
@onready var controls_button: Button = $MenuFrame/VBoxContainer/ControlsButton
@onready var quit_button: Button = $MenuFrame/VBoxContainer/QuitButton
@onready var controls_modal: Control = $ControlsModal
@onready var close_controls_button: Button = $ControlsModal/ModalFrame/VBox/CloseButton

func _ready() -> void:
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	if controls_button:
		controls_button.pressed.connect(_on_controls_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	if close_controls_button:
		close_controls_button.pressed.connect(_on_close_controls_pressed)

func _on_play_pressed() -> void:
	GameManager.current_fight = 0
	get_tree().change_scene_to_file("res://scenes/campaign/arena.tscn")

func _on_controls_pressed() -> void:
	if controls_modal:
		controls_modal.visible = true

func _on_close_controls_pressed() -> void:
	if controls_modal:
		controls_modal.visible = false

func _on_quit_pressed() -> void:
	get_tree().quit()
