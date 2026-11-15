extends Node
## Comprehensive automated test suite for controller/gamepad support in Bouncy Brawl 3000.
## Tests InputMap bindings, analog deadzones, device isolation, simulated gamepad actions,
## 2-player multiplayer assignments, controller disconnect safety, and UI navigation.

var passed: int = 0
var failed: int = 0

func _ready() -> void:
	print("========================================")
	print(" RUNNING CONTROLLER SUPPORT AUTOMATED TESTS")
	print("========================================")

	_test_input_map_actions()
	_test_analog_deadzone()
	_test_gameplay_actions()
	_test_device_isolation()
	_test_keyboard_and_controller_multiplayer()
	_test_controller_disconnect_safety()
	_test_ui_menu_navigation()
	_test_button_prompts()

	print("\n========================================")
	print(" FINAL CONTROLLER RESULTS: ", passed, " PASSED, ", failed, " FAILED")
	print("========================================")

	if failed == 0:
		print(">>> ALL CONTROLLER SUPPORT TESTS PASSED! <<<")
	else:
		print(">>> CONTROLLER SUPPORT VERIFICATION FAILED! <<<")

	get_tree().quit(0 if failed == 0 else 1)

func assert_check(condition: bool, description: String) -> void:
	if condition:
		print("  [PASS] ", description)
		passed += 1
	else:
		print("  [FAIL] ", description)
		failed += 1

func _send_joy_button(device: int, button: JoyButton, pressed: bool) -> void:
	var ev = InputEventJoypadButton.new()
	ev.device = device
	ev.button_index = button
	ev.pressed = pressed
	Input.parse_input_event(ev)
	Input.flush_buffered_events()

func _send_joy_motion(device: int, axis: JoyAxis, value: float) -> void:
	var ev = InputEventJoypadMotion.new()
	ev.device = device
	ev.axis = axis
	ev.axis_value = value
	Input.parse_input_event(ev)
	Input.flush_buffered_events()

func _send_key(keycode: Key, pressed: bool) -> void:
	var ev = InputEventKey.new()
	ev.physical_keycode = keycode
	ev.pressed = pressed
	Input.parse_input_event(ev)
	Input.flush_buffered_events()

func _test_input_map_actions() -> void:
	print("\n[TEST 1] InputMap Controller & Player Actions")

	var p1_actions = ["p1_left", "p1_right", "p1_up", "p1_down", "p1_jump", "p1_attack", "p1_pause"]
	for act in p1_actions:
		assert_check(InputMap.has_action(act), "InputMap contains P1 action: " + act)

	var p2_actions = ["p2_left", "p2_right", "p2_up", "p2_down", "p2_jump", "p2_attack", "p2_pause"]
	for act in p2_actions:
		assert_check(InputMap.has_action(act), "InputMap contains P2 action: " + act)

	var ui_actions = ["ui_left", "ui_right", "ui_up", "ui_down", "ui_accept", "ui_cancel", "ui_pause"]
	for act in ui_actions:
		assert_check(InputMap.has_action(act), "InputMap contains UI action: " + act)

	# Verify P1 joypad bindings
	var p1_jump_events = InputMap.action_get_events("p1_jump")
	var has_joy_jump = false
	for ev in p1_jump_events:
		if ev is InputEventJoypadButton and ev.button_index == JoyButton.JOY_BUTTON_A:
			has_joy_jump = true
			break
	assert_check(has_joy_jump, "p1_jump has Joypad A (Button 0) event")

	var p1_attack_events = InputMap.action_get_events("p1_attack")
	var has_joy_attack = false
	for ev in p1_attack_events:
		if ev is InputEventJoypadButton and ev.button_index == JoyButton.JOY_BUTTON_X:
			has_joy_attack = true
			break
	assert_check(has_joy_attack, "p1_attack has Joypad X (Button 2) event")

	var p1_pause_events = InputMap.action_get_events("p1_pause")
	var has_joy_pause = false
	for ev in p1_pause_events:
		if ev is InputEventJoypadButton and ev.button_index == JoyButton.JOY_BUTTON_START:
			has_joy_pause = true
			break
	assert_check(has_joy_pause, "p1_pause has Joypad Start (Button 6) event")

	# Verify P1 motion deadzone
	assert_check(InputMap.action_get_deadzone("p1_left") >= 0.2, "p1_left deadzone is >= 0.2")
	assert_check(InputMap.action_get_deadzone("p1_right") >= 0.2, "p1_right deadzone is >= 0.2")

func _test_analog_deadzone() -> void:
	print("\n[TEST 2] Analog Deadzone & Stick Drift Filtering")

	# Below deadzone (0.15 tilt): Input.get_axis should produce 0.0
	_send_joy_motion(0, JoyAxis.JOY_AXIS_LEFT_X, 0.15)
	var sub_axis = Input.get_axis("p1_left", "p1_right")
	assert_check(is_zero_approx(sub_axis), "Sub-deadzone tilt (0.15) produces 0.0 axis value (no stick drift)")

	# Above deadzone (0.8 tilt): Input.get_axis should produce positive value
	_send_joy_motion(0, JoyAxis.JOY_AXIS_LEFT_X, 0.8)
	var above_axis = Input.get_axis("p1_left", "p1_right")
	assert_check(above_axis > 0.5, "Tilt above deadzone (0.8) produces proportional axis value: " + str(above_axis))

	# Negative tilt above deadzone (-0.8 tilt)
	_send_joy_motion(0, JoyAxis.JOY_AXIS_LEFT_X, -0.8)
	var neg_axis = Input.get_axis("p1_left", "p1_right")
	assert_check(neg_axis < -0.5, "Tilt left above deadzone (-0.8) produces negative axis value: " + str(neg_axis))

	# Return to center (0.0)
	_send_joy_motion(0, JoyAxis.JOY_AXIS_LEFT_X, 0.0)
	assert_check(is_zero_approx(Input.get_axis("p1_left", "p1_right")), "Centering stick returns axis to 0.0")

func _test_gameplay_actions() -> void:
	print("\n[TEST 3] Simulated Gamepad Actions on Player Character")

	var player_scene = load("res://scenes/entities/player.tscn")
	var player = player_scene.instantiate()
	add_child(player)

	# Verify initial state
	assert_check(player.player_id == 1, "Player defaults to player_id = 1")
	assert_check(player.input_prefix == "p1_", "Player input_prefix is 'p1_'")

	# Test Joypad Button A press -> Jump
	_send_joy_button(0, JoyButton.JOY_BUTTON_A, true)
	assert_check(Input.is_action_pressed("p1_jump"), "Joypad Button A registers p1_jump action pressed")

	# Release jump button
	_send_joy_button(0, JoyButton.JOY_BUTTON_A, false)
	assert_check(not Input.is_action_pressed("p1_jump"), "Joypad Button A release registers p1_jump released")

	# Test Joypad Button X press -> Attack
	_send_joy_button(0, JoyButton.JOY_BUTTON_X, true)
	assert_check(Input.is_action_pressed("p1_attack"), "Joypad Button X registers p1_attack action pressed")

	# Release attack button
	_send_joy_button(0, JoyButton.JOY_BUTTON_X, false)
	assert_check(not Input.is_action_pressed("p1_attack"), "Joypad Button X release registers p1_attack released")

	# Test D-Pad Left movement
	_send_joy_button(0, JoyButton.JOY_BUTTON_DPAD_LEFT, true)
	assert_check(Input.is_action_pressed("p1_left"), "Joypad D-Pad Left registers p1_left pressed")
	assert_check(Input.get_axis("p1_left", "p1_right") < -0.9, "D-Pad Left sets horizontal axis to -1.0")

	_send_joy_button(0, JoyButton.JOY_BUTTON_DPAD_LEFT, false)

	# Test D-Pad Right movement
	_send_joy_button(0, JoyButton.JOY_BUTTON_DPAD_RIGHT, true)
	assert_check(Input.is_action_pressed("p1_right"), "Joypad D-Pad Right registers p1_right pressed")
	assert_check(Input.get_axis("p1_left", "p1_right") > 0.9, "D-Pad Right sets horizontal axis to 1.0")

	_send_joy_button(0, JoyButton.JOY_BUTTON_DPAD_RIGHT, false)

	player.queue_free()

func _test_device_isolation() -> void:
	print("\n[TEST 4] Two-Player Device Isolation")

	var im = GameManager.input_manager
	assert_check(im != null, "InputManager singleton exists")

	# Test Device 0 button does not trigger P2
	_send_joy_button(0, JoyButton.JOY_BUTTON_A, true)
	assert_check(Input.is_action_pressed("p1_jump"), "Device 0 Button A triggers p1_jump")
	assert_check(not Input.is_action_pressed("p2_jump"), "Device 0 Button A DOES NOT trigger p2_jump (Device Isolation)")

	_send_joy_button(0, JoyButton.JOY_BUTTON_A, false)

	# Test Device 1 button does not trigger P1
	_send_joy_button(1, JoyButton.JOY_BUTTON_A, true)
	assert_check(Input.is_action_pressed("p2_jump"), "Device 1 Button A triggers p2_jump")
	assert_check(not Input.is_action_pressed("p1_jump"), "Device 1 Button A DOES NOT trigger p1_jump (Device Isolation)")

	_send_joy_button(1, JoyButton.JOY_BUTTON_A, false)

	# Test Device 0 Left Stick does not affect P2 horizontal axis
	_send_joy_motion(0, JoyAxis.JOY_AXIS_LEFT_X, 0.9)
	assert_check(Input.get_axis("p1_left", "p1_right") > 0.5, "Device 0 stick moves P1 right")
	assert_check(is_zero_approx(Input.get_axis("p2_left", "p2_right")), "Device 0 stick DOES NOT move P2 (axis is 0.0)")

	_send_joy_motion(0, JoyAxis.JOY_AXIS_LEFT_X, 0.0)

	# Test Device 1 Left Stick does not affect P1 horizontal axis
	_send_joy_motion(1, JoyAxis.JOY_AXIS_LEFT_X, -0.9)
	assert_check(Input.get_axis("p2_left", "p2_right") < -0.5, "Device 1 stick moves P2 left")
	assert_check(is_zero_approx(Input.get_axis("p1_left", "p1_right")), "Device 1 stick DOES NOT move P1 (axis is 0.0)")

	_send_joy_motion(1, JoyAxis.JOY_AXIS_LEFT_X, 0.0)

func _test_keyboard_and_controller_multiplayer() -> void:
	print("\n[TEST 5] Keyboard + Controller Multiplayer Mode")

	var im = GameManager.input_manager

	# Switch mode to KEYBOARD_AND_CONTROLLER
	im.set_multiplayer_mode(im.MultiplayerMode.KEYBOARD_AND_CONTROLLER)
	assert_check(im.multiplayer_mode == im.MultiplayerMode.KEYBOARD_AND_CONTROLLER, "Multiplayer mode set to KEYBOARD_AND_CONTROLLER")
	assert_check(im.get_player_device(1) == -1, "Player 1 assigned device is -1 (Keyboard)")
	assert_check(im.get_player_device(2) == 0, "Player 2 assigned device is 0 (Controller)")

	# Verify Controller 0 now controls P2, not P1
	_send_joy_button(0, JoyButton.JOY_BUTTON_A, true)
	assert_check(Input.is_action_pressed("p2_jump"), "Controller 0 triggers P2 jump in KEYBOARD_AND_CONTROLLER mode")
	assert_check(not Input.is_action_pressed("p1_jump"), "Controller 0 DOES NOT trigger P1 jump in KEYBOARD_AND_CONTROLLER mode")

	_send_joy_button(0, JoyButton.JOY_BUTTON_A, false)

	# Verify Keyboard Space still triggers P1 jump
	_send_key(KEY_SPACE, true)
	assert_check(Input.is_action_pressed("p1_jump"), "Keyboard Space triggers P1 jump")

	_send_key(KEY_SPACE, false)

	# Reset mode back to AUTO
	im.set_multiplayer_mode(im.MultiplayerMode.AUTO)
	assert_check(im.multiplayer_mode == im.MultiplayerMode.AUTO, "Multiplayer mode restored to AUTO")

func _test_controller_disconnect_safety() -> void:
	print("\n[TEST 6] Controller Disconnect Safety & Action Release")

	var im = GameManager.input_manager

	# Simulate button pressed
	_send_joy_button(0, JoyButton.JOY_BUTTON_A, true)
	assert_check(Input.is_action_pressed("p1_jump"), "p1_jump is initially pressed before disconnect")

	# Track disconnect signal
	var disconnected_device = [-1]
	var disconnected_player = [-1]
	var on_disconnected = func(dev: int, player: int):
		disconnected_device[0] = dev
		disconnected_player[0] = player

	im.controller_disconnected.connect(on_disconnected)

	# Trigger disconnection of controller 0
	im._on_joy_connection_changed(0, false)

	# Verify safety release
	assert_check(not Input.is_action_pressed("p1_jump"), "All held player actions safely released on controller disconnect")
	assert_check(disconnected_device[0] == 0, "controller_disconnected signal emitted with device 0")

	im.controller_disconnected.disconnect(on_disconnected)

	# Reconnect controller 0
	var connected_device = [-1]
	var on_connected = func(dev: int, _player: int):
		connected_device[0] = dev
	im.controller_connected.connect(on_connected)

	im._on_joy_connection_changed(0, true)
	assert_check(connected_device[0] == 0, "controller_connected signal emitted on reconnection")

	im.controller_connected.disconnect(on_connected)

func _test_ui_menu_navigation() -> void:
	print("\n[TEST 7] UI Menu Navigation & Gamepad Bindings")

	# Test ui_accept with Joypad Button A (any device: device -1)
	_send_joy_button(0, JoyButton.JOY_BUTTON_A, true)
	assert_check(Input.is_action_pressed("ui_accept"), "Joypad Button A triggers ui_accept for menu confirmation")
	_send_joy_button(0, JoyButton.JOY_BUTTON_A, false)

	# Test ui_cancel with Joypad Button B
	_send_joy_button(0, JoyButton.JOY_BUTTON_B, true)
	assert_check(Input.is_action_pressed("ui_cancel"), "Joypad Button B triggers ui_cancel for menu return")
	_send_joy_button(0, JoyButton.JOY_BUTTON_B, false)

	# Test ui_pause with Joypad Start
	_send_joy_button(0, JoyButton.JOY_BUTTON_START, true)
	assert_check(Input.is_action_pressed("ui_pause"), "Joypad Start triggers ui_pause")
	_send_joy_button(0, JoyButton.JOY_BUTTON_START, false)

	# Verify PauseMenu and FightResult grab focus
	var pause_menu_scene = load("res://scenes/ui/pause_menu.tscn")
	var pause_menu = pause_menu_scene.instantiate()
	add_child(pause_menu)
	pause_menu.show_pause()
	assert_check(pause_menu.visible == true, "PauseMenu is visible after show_pause()")
	assert_check(pause_menu.resume_button.has_focus(), "Resume button has UI focus for immediate controller selection")
	pause_menu._on_resume()
	pause_menu.queue_free()

	var fight_result_scene = load("res://scenes/ui/fight_result.tscn")
	var fight_result = fight_result_scene.instantiate()
	add_child(fight_result)
	fight_result.show_defeat()
	assert_check(fight_result.visible == true, "FightResult defeat is visible")
	assert_check(fight_result.retry_button.has_focus(), "Retry button has UI focus for immediate controller retry")
	fight_result._on_retry()
	fight_result.queue_free()

func _test_button_prompts() -> void:
	print("\n[TEST 8] Dynamic Button Prompts")

	var im = GameManager.input_manager

	assert_check(im.get_button_prompt("p1_jump", true) == "A / ✕", "Controller jump prompt is 'A / ✕'")
	assert_check(im.get_button_prompt("p1_jump", false) == "Space", "Keyboard jump prompt is 'Space'")
	assert_check(im.get_button_prompt("p1_attack", true) == "X / ▢", "Controller attack prompt is 'X / ▢'")
	assert_check(im.get_button_prompt("p1_attack", false) == "J", "Keyboard attack prompt is 'J'")
	assert_check(im.get_button_prompt("p1_pause", true) == "Start / Options", "Controller pause prompt is 'Start / Options'")
	assert_check(im.get_button_prompt("p1_pause", false) == "Esc", "Keyboard pause prompt is 'Esc'")
