extends CanvasLayer
## Victory/Defeat overlay with retry and continue options, supporting gamepad navigation.

@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var message_label: Label = $Panel/VBoxContainer/MessageLabel
@onready var continue_button: Button = $Panel/VBoxContainer/ContinueButton
@onready var retry_button: Button = $Panel/VBoxContainer/RetryButton
@onready var title_button: Button = $Panel/VBoxContainer/TitleButton

signal retry_requested()
signal continue_requested()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	continue_button.pressed.connect(_on_continue)
	retry_button.pressed.connect(_on_retry)
	title_button.pressed.connect(_on_title)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_title()

func show_victory() -> void:
	visible = true
	get_tree().paused = true
	title_label.text = "VICTORY!"
	title_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3, 1))
	message_label.text = GameManager.get_boss_name() + " has been defeated!"

	if GameManager.has_next_fight():
		continue_button.visible = true
		continue_button.text = "Next Fight"
	else:
		continue_button.visible = true
		continue_button.text = "Campaign Complete!"

	retry_button.visible = false
	continue_button.grab_focus()

func show_defeat() -> void:
	visible = true
	get_tree().paused = true
	title_label.text = "DEFEAT"
	title_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3, 1))
	message_label.text = "You were defeated by " + GameManager.get_boss_name() + "..."
	continue_button.visible = false
	retry_button.visible = true
	retry_button.grab_focus()

func show_campaign_complete() -> void:
	visible = true
	get_tree().paused = true
	title_label.text = "CAMPAIGN COMPLETE!"
	title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1))
	message_label.text = "You defeated all three bosses!\nYou are the Bouncy Brawl Champion!"
	continue_button.visible = false
	retry_button.visible = false
	title_button.grab_focus()

func _on_continue() -> void:
	visible = false
	get_tree().paused = false
	if GameManager.has_next_fight():
		continue_requested.emit()
	else:
		show_campaign_complete()

func _on_retry() -> void:
	visible = false
	get_tree().paused = false
	retry_requested.emit()

func _on_title() -> void:
	visible = false
	get_tree().paused = false
	GameManager.fight_state = GameManager.FightState.NONE
	get_tree().change_scene_to_file("res://scenes/ui/title_screen.tscn")
