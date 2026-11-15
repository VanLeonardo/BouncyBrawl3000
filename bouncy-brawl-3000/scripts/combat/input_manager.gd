extends Node
## Central input and gamepad controller manager for Bouncy Brawl 3000.
## Handles controller connection/disconnection, device assignment, analog deadzones,
## 2-player local mapping, and dynamic device prompt detection.

signal controller_connected(device_id: int, assigned_player: int)
signal controller_disconnected(device_id: int, assigned_player: int)
signal input_device_changed(is_controller: bool, device_id: int)
signal player_device_reassigned(player_id: int, device_id: int)

enum DeviceType { KEYBOARD, CONTROLLER }
enum MultiplayerMode { AUTO, TWO_CONTROLLERS, KEYBOARD_AND_CONTROLLER }

const DEADZONE: float = 0.25

# Player device assignments: -1 = Keyboard (or unassigned), 0 = Joypad 0, 1 = Joypad 1, etc.
var player_devices: Dictionary = {
	1: 0,
	2: 1
}

var multiplayer_mode: MultiplayerMode = MultiplayerMode.AUTO
var connected_controllers: Array[int] = []
var last_device_type: DeviceType = DeviceType.KEYBOARD
var last_controller_id: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_scan_connected_controllers()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_setup_input_map()
	_update_device_assignments()

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		if last_device_type != DeviceType.KEYBOARD:
			last_device_type = DeviceType.KEYBOARD
			input_device_changed.emit(false, -1)
	elif event is InputEventJoypadButton:
		last_controller_id = event.device
		if last_device_type != DeviceType.CONTROLLER:
			last_device_type = DeviceType.CONTROLLER
			input_device_changed.emit(true, event.device)
	elif event is InputEventJoypadMotion:
		if absf(event.axis_value) >= DEADZONE:
			last_controller_id = event.device
			if last_device_type != DeviceType.CONTROLLER:
				last_device_type = DeviceType.CONTROLLER
				input_device_changed.emit(true, event.device)

func _scan_connected_controllers() -> void:
	connected_controllers.clear()
	var joypads = Input.get_connected_joypads()
	for j in joypads:
		connected_controllers.append(j)

func _on_joy_connection_changed(device: int, connected: bool) -> void:
	if connected:
		if device not in connected_controllers:
			connected_controllers.append(device)
		_update_device_assignments()
		var assigned_p = get_player_for_device(device)
		controller_connected.emit(device, assigned_p)
	else:
		if device in connected_controllers:
			connected_controllers.erase(device)
		# Release any held actions for safety on disconnect
		_release_all_player_actions()
		var assigned_p = get_player_for_device(device)
		_update_device_assignments()
		controller_disconnected.emit(device, assigned_p)

func _update_device_assignments() -> void:
	match multiplayer_mode:
		MultiplayerMode.KEYBOARD_AND_CONTROLLER:
			# Player 1 is keyboard only; Player 2 gets the first available controller
			player_devices[1] = -1
			if connected_controllers.size() > 0:
				player_devices[2] = connected_controllers[0]
			else:
				player_devices[2] = 0
		MultiplayerMode.TWO_CONTROLLERS:
			# P1 gets first controller, P2 gets second controller
			if connected_controllers.size() >= 2:
				player_devices[1] = connected_controllers[0]
				player_devices[2] = connected_controllers[1]
			elif connected_controllers.size() == 1:
				player_devices[1] = connected_controllers[0]
				player_devices[2] = 1  # Waiting for second controller
			else:
				player_devices[1] = 0
				player_devices[2] = 1
		MultiplayerMode.AUTO:
			# Auto: If 0 controllers: P1=Kbd, P2=Kbd
			# If 1 controller: P1=Controller 0 (and keyboard). P2=waiting/Kbd.
			# If 2+ controllers: P1=Controller 0, P2=Controller 1.
			if connected_controllers.size() >= 2:
				player_devices[1] = connected_controllers[0]
				player_devices[2] = connected_controllers[1]
			elif connected_controllers.size() == 1:
				player_devices[1] = connected_controllers[0]
				player_devices[2] = 1
			else:
				player_devices[1] = 0
				player_devices[2] = 1

	_apply_device_assignments_to_input_map()

func set_multiplayer_mode(mode: MultiplayerMode) -> void:
	multiplayer_mode = mode
	_update_device_assignments()

func assign_controller_to_player(player_id: int, device_id: int) -> void:
	player_devices[player_id] = device_id
	_apply_device_assignments_to_input_map()
	player_device_reassigned.emit(player_id, device_id)

func get_player_device(player_id: int) -> int:
	return player_devices.get(player_id, -1)

func get_player_for_device(device_id: int) -> int:
	for p_id in player_devices.keys():
		if player_devices[p_id] == device_id:
			return p_id
	return 0

func _release_all_player_actions() -> void:
	var actions = [
		"p1_left", "p1_right", "p1_up", "p1_down", "p1_jump", "p1_attack", "p1_pause",
		"p2_left", "p2_right", "p2_up", "p2_down", "p2_jump", "p2_attack", "p2_pause",
		"ui_left", "ui_right", "ui_up", "ui_down", "ui_accept", "ui_cancel", "ui_pause"
	]
	for act in actions:
		if InputMap.has_action(act):
			Input.action_release(act)

func _setup_input_map() -> void:
	# Configure actions if not already present
	_ensure_action("p1_left")
	_ensure_action("p1_right")
	_ensure_action("p1_up")
	_ensure_action("p1_down")
	_ensure_action("p1_jump")
	_ensure_action("p1_attack")
	_ensure_action("p1_pause")

	_ensure_action("p2_left")
	_ensure_action("p2_right")
	_ensure_action("p2_up")
	_ensure_action("p2_down")
	_ensure_action("p2_jump")
	_ensure_action("p2_attack")
	_ensure_action("p2_pause")

	_ensure_action("ui_left")
	_ensure_action("ui_right")
	_ensure_action("ui_up")
	_ensure_action("ui_down")
	_ensure_action("ui_accept")
	_ensure_action("ui_cancel")
	_ensure_action("ui_pause")

	# Set action deadzones
	for act in ["p1_left", "p1_right", "p1_up", "p1_down", "p2_left", "p2_right", "p2_up", "p2_down", "ui_left", "ui_right", "ui_up", "ui_down"]:
		if InputMap.has_action(act):
			InputMap.action_set_deadzone(act, DEADZONE)

	_populate_keyboard_events()
	_populate_controller_events()
	_populate_ui_events()

func _ensure_action(action_name: String) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name, DEADZONE)

func _populate_keyboard_events() -> void:
	# Player 1 Keyboard: WASD / Arrow Keys, Space, J/Z, Esc/P
	_add_key_if_missing("p1_left", KEY_A)
	_add_key_if_missing("p1_left", KEY_LEFT)
	_add_key_if_missing("p1_right", KEY_D)
	_add_key_if_missing("p1_right", KEY_RIGHT)
	_add_key_if_missing("p1_up", KEY_W)
	_add_key_if_missing("p1_up", KEY_UP)
	_add_key_if_missing("p1_down", KEY_S)
	_add_key_if_missing("p1_down", KEY_DOWN)
	_add_key_if_missing("p1_jump", KEY_SPACE)
	_add_key_if_missing("p1_jump", KEY_W)
	_add_key_if_missing("p1_jump", KEY_UP)
	_add_key_if_missing("p1_attack", KEY_J)
	_add_key_if_missing("p1_attack", KEY_Z)
	_add_key_if_missing("p1_pause", KEY_ESCAPE)
	_add_key_if_missing("p1_pause", KEY_P)

	# Player 2 Keyboard: Numpad / IJKL, Slash / Keypad 0, Period / Keypad 1
	_add_key_if_missing("p2_left", KEY_KP_4)
	_add_key_if_missing("p2_left", KEY_J)
	_add_key_if_missing("p2_right", KEY_KP_6)
	_add_key_if_missing("p2_right", KEY_L)
	_add_key_if_missing("p2_up", KEY_KP_8)
	_add_key_if_missing("p2_up", KEY_I)
	_add_key_if_missing("p2_down", KEY_KP_2)
	_add_key_if_missing("p2_down", KEY_KP_5)
	_add_key_if_missing("p2_down", KEY_K)
	_add_key_if_missing("p2_jump", KEY_KP_0)
	_add_key_if_missing("p2_jump", KEY_KP_ENTER)
	_add_key_if_missing("p2_jump", KEY_SLASH)
	_add_key_if_missing("p2_attack", KEY_KP_1)
	_add_key_if_missing("p2_attack", KEY_PERIOD)
	_add_key_if_missing("p2_pause", KEY_KP_ADD)
	_add_key_if_missing("p2_pause", KEY_BACKSLASH)

func _populate_controller_events() -> void:
	# Add controller events for Player 1 (Device 0) and Player 2 (Device 1)
	_setup_player_joypad_events(1, player_devices[1])
	_setup_player_joypad_events(2, player_devices[2])

func _populate_ui_events() -> void:
	# UI Menu Navigation
	_add_key_if_missing("ui_accept", KEY_ENTER)
	_add_key_if_missing("ui_accept", KEY_SPACE)
	_add_joy_button_if_missing("ui_accept", JoyButton.JOY_BUTTON_A, -1)

	_add_key_if_missing("ui_cancel", KEY_ESCAPE)
	_add_joy_button_if_missing("ui_cancel", JoyButton.JOY_BUTTON_B, -1)

	_add_key_if_missing("ui_up", KEY_UP)
	_add_key_if_missing("ui_up", KEY_W)
	_add_joy_button_if_missing("ui_up", JoyButton.JOY_BUTTON_DPAD_UP, -1)
	_add_joy_motion_if_missing("ui_up", JoyAxis.JOY_AXIS_LEFT_Y, -1.0, -1)

	_add_key_if_missing("ui_down", KEY_DOWN)
	_add_key_if_missing("ui_down", KEY_S)
	_add_joy_button_if_missing("ui_down", JoyButton.JOY_BUTTON_DPAD_DOWN, -1)
	_add_joy_motion_if_missing("ui_down", JoyAxis.JOY_AXIS_LEFT_Y, 1.0, -1)

	_add_key_if_missing("ui_left", KEY_LEFT)
	_add_key_if_missing("ui_left", KEY_A)
	_add_joy_button_if_missing("ui_left", JoyButton.JOY_BUTTON_DPAD_LEFT, -1)
	_add_joy_motion_if_missing("ui_left", JoyAxis.JOY_AXIS_LEFT_X, -1.0, -1)

	_add_key_if_missing("ui_right", KEY_RIGHT)
	_add_key_if_missing("ui_right", KEY_D)
	_add_joy_button_if_missing("ui_right", JoyButton.JOY_BUTTON_DPAD_RIGHT, -1)
	_add_joy_motion_if_missing("ui_right", JoyAxis.JOY_AXIS_LEFT_X, 1.0, -1)

	_add_key_if_missing("ui_pause", KEY_ESCAPE)
	_add_key_if_missing("ui_pause", KEY_P)
	_add_joy_button_if_missing("ui_pause", JoyButton.JOY_BUTTON_START, -1)

func _setup_player_joypad_events(player_id: int, device_id: int) -> void:
	var prefix = "p%d_" % player_id

	# Left / Right (Stick X axis + D-Pad)
	_add_joy_motion_if_missing(prefix + "left", JoyAxis.JOY_AXIS_LEFT_X, -1.0, device_id)
	_add_joy_button_if_missing(prefix + "left", JoyButton.JOY_BUTTON_DPAD_LEFT, device_id)

	_add_joy_motion_if_missing(prefix + "right", JoyAxis.JOY_AXIS_LEFT_X, 1.0, device_id)
	_add_joy_button_if_missing(prefix + "right", JoyButton.JOY_BUTTON_DPAD_RIGHT, device_id)

	# Up / Down (Stick Y axis + D-Pad)
	_add_joy_motion_if_missing(prefix + "up", JoyAxis.JOY_AXIS_LEFT_Y, -1.0, device_id)
	_add_joy_button_if_missing(prefix + "up", JoyButton.JOY_BUTTON_DPAD_UP, device_id)

	_add_joy_motion_if_missing(prefix + "down", JoyAxis.JOY_AXIS_LEFT_Y, 1.0, device_id)
	_add_joy_button_if_missing(prefix + "down", JoyButton.JOY_BUTTON_DPAD_DOWN, device_id)

	# Jump: Joypad A / Cross (button 0)
	_add_joy_button_if_missing(prefix + "jump", JoyButton.JOY_BUTTON_A, device_id)

	# Attack: Joypad X / Square (button 2)
	_add_joy_button_if_missing(prefix + "attack", JoyButton.JOY_BUTTON_X, device_id)

	# Pause: Joypad Start / Options (button 6)
	_add_joy_button_if_missing(prefix + "pause", JoyButton.JOY_BUTTON_START, device_id)

func _apply_device_assignments_to_input_map() -> void:
	for p_id in [1, 2]:
		var prefix = "p%d_" % p_id
		var dev = player_devices[p_id]
		# When dev is -1 (keyboard only), assign to an inactive joypad index (999) so joypad events don't match all devices
		var joy_device = dev if dev >= 0 else 999
		var actions = [prefix + "left", prefix + "right", prefix + "up", prefix + "down", prefix + "jump", prefix + "attack", prefix + "pause"]
		for act in actions:
			if InputMap.has_action(act):
				for ev in InputMap.action_get_events(act):
					if ev is InputEventJoypadButton or ev is InputEventJoypadMotion:
						ev.device = joy_device

func _add_key_if_missing(action: String, keycode: Key) -> void:
	if not InputMap.has_action(action):
		return
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey and ev.physical_keycode == keycode:
			return
	var key_ev = InputEventKey.new()
	key_ev.physical_keycode = keycode
	key_ev.pressed = false
	InputMap.action_add_event(action, key_ev)

func _add_joy_button_if_missing(action: String, button: JoyButton, device: int) -> void:
	if not InputMap.has_action(action):
		return
	for ev in InputMap.action_get_events(action):
		if ev is InputEventJoypadButton and ev.button_index == button and ev.device == device:
			return
	var btn_ev = InputEventJoypadButton.new()
	btn_ev.button_index = button
	btn_ev.device = device
	InputMap.action_add_event(action, btn_ev)

func _add_joy_motion_if_missing(action: String, axis: JoyAxis, axis_value: float, device: int) -> void:
	if not InputMap.has_action(action):
		return
	for ev in InputMap.action_get_events(action):
		if ev is InputEventJoypadMotion and ev.axis == axis and signf(ev.axis_value) == signf(axis_value) and ev.device == device:
			return
	var motion_ev = InputEventJoypadMotion.new()
	motion_ev.axis = axis
	motion_ev.axis_value = axis_value
	motion_ev.device = device
	InputMap.action_add_event(action, motion_ev)

func get_button_prompt(action_name: String, force_controller: Variant = null) -> String:
	var use_controller: bool = (last_device_type == DeviceType.CONTROLLER) if force_controller == null else bool(force_controller)
	match action_name:
		"p1_jump", "jump":
			return "A / ✕" if use_controller else "Space"
		"p1_attack", "attack":
			return "X / ▢" if use_controller else "J"
		"p1_pause", "pause":
			return "Start / Options" if use_controller else "Esc"
		"p1_left", "left":
			return "Left Stick / D-Pad Left" if use_controller else "A / ←"
		"p1_right", "right":
			return "Left Stick / D-Pad Right" if use_controller else "D / →"
		"p1_down", "down":
			return "Left Stick Down / D-Pad Down" if use_controller else "S / ↓"
		"ui_accept", "accept":
			return "A / ✕" if use_controller else "Enter"
		"ui_cancel", "cancel":
			return "B / ◯" if use_controller else "Esc"
		_:
			return action_name
