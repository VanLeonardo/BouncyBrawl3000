extends Control
## Title Screen controller for Bouncy Brawl 3000 with gamepad controller navigation.

@onready var play_button: Button = $MenuFrame/VBoxContainer/PlayButton
@onready var controls_button: Button = $MenuFrame/VBoxContainer/ControlsButton
@onready var quit_button: Button = $MenuFrame/VBoxContainer/QuitButton
@onready var controls_modal: Control = $ControlsModal
@onready var close_controls_button: Button = $ControlsModal/ModalFrame/VBox/CloseButton
@onready var device_badge: Label = $ControlsModal/ModalFrame/VBox/DeviceBadge

func _ready() -> void:
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
		play_button.grab_focus()
	if controls_button:
		controls_button.pressed.connect(_on_controls_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	if close_controls_button:
		close_controls_button.pressed.connect(_on_close_controls_pressed)

	if GameManager.input_manager:
		GameManager.input_manager.input_device_changed.connect(_on_input_device_changed)
		_update_device_badge(GameManager.input_manager.last_device_type == GameManager.input_manager.DeviceType.CONTROLLER)

func _unhandled_input(event: InputEvent) -> void:
	if controls_modal and controls_modal.visible:
		if event.is_action_pressed("ui_cancel"):
			_on_close_controls_pressed()

func _on_play_pressed() -> void:
	GameManager.current_fight = 0
	get_tree().change_scene_to_file("res://scenes/campaign/arena.tscn")

func _on_controls_pressed() -> void:
	if controls_modal:
		controls_modal.visible = true
		if close_controls_button:
			close_controls_button.grab_focus()

func _on_close_controls_pressed() -> void:
	if controls_modal:
		controls_modal.visible = false
		if controls_button:
			controls_button.grab_focus()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_input_device_changed(is_controller: bool, _device_id: int) -> void:
	_update_device_badge(is_controller)

func _update_device_badge(is_controller: bool) -> void:
	if device_badge:
		if is_controller:
			device_badge.text = "🎮 ACTIVE INPUT: CONTROLLER (Xbox / PlayStation / Generic)"
			device_badge.modulate = Color(0.4, 0.9, 1.0)
		else:
			device_badge.text = "⌨ ACTIVE INPUT: KEYBOARD"
			device_badge.modulate = Color(1.0, 0.9, 0.4)
