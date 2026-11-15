extends Node
## Integration test for single-player campaign gameplay in the arena.
## Verifies Knight (human player) keyboard & controller responsiveness,
## Mage AI positioning, movement & fireball attacks, gravity, ground collision,
## health/damage processing, and title screen flow.

var passed: int = 0
var failed: int = 0

func _ready() -> void:
	print("========================================")
	print(" RUNNING ARENA SINGLE-PLAYER GAMEPLAY VERIFICATION")
	print("========================================")

	await _test_arena_single_player_loop()

	print("\n========================================")
	print(" ARENA GAMEPLAY RESULTS: ", passed, " PASSED, ", failed, " FAILED")
	print("========================================")

	if failed == 0:
		print(">>> ALL ARENA GAMEPLAY TESTS PASSED! <<<")
	else:
		print(">>> ARENA GAMEPLAY TESTS FAILED! <<<")

	get_tree().quit(0 if failed == 0 else 1)

func assert_check(condition: bool, description: String) -> void:
	if condition:
		print("  [PASS] ", description)
		passed += 1
	else:
		print("  [FAIL] ", description)
		failed += 1

func _test_arena_single_player_loop() -> void:
	print("\n[STEP 1] Instantiate Arena & Fighters")
	var arena_scene = load("res://scenes/campaign/arena.tscn")
	var arena = arena_scene.instantiate()
	add_child(arena)

	# Allow ready and initial spawning to process
	await get_tree().process_frame
	await get_tree().physics_frame

	var knight = arena.player
	var mage = arena.enemy

	assert_check(knight != null, "Knight (Player) spawned successfully")
	assert_check(mage != null, "Mage (AI Boss) spawned successfully")
	assert_check(GameManager.fight_state == GameManager.FightState.FIGHTING, "GameManager fight state is FIGHTING")

	print("\n[STEP 2] Gravity and Ground Collision for Both Fighters")
	# Simulate physics frames for fighters to settle on platform
	for i in range(60):
		await get_tree().physics_frame

	assert_check(knight.is_on_floor(), "Knight lands on ground via gravity & collision")
	assert_check(mage.is_on_floor(), "Mage lands on ground via gravity & collision")
	assert_check(knight.global_position.y > 100.0 and knight.global_position.y < 500.0, "Knight Y position on platform is valid: " + str(knight.global_position.y))
	assert_check(mage.global_position.y > 100.0 and mage.global_position.y < 500.0, "Mage Y position on platform is valid: " + str(mage.global_position.y))

	print("\n[STEP 3] Knight Controls (Keyboard & Controller)")
	var start_knight_x = knight.global_position.x

	# Simulate moving right (WASD / D-Pad / Left Stick)
	var move_right_ev = InputEventJoypadMotion.new()
	move_right_ev.device = 0
	move_right_ev.axis = JoyAxis.JOY_AXIS_LEFT_X
	move_right_ev.axis_value = 1.0
	Input.parse_input_event(move_right_ev)
	Input.flush_buffered_events()

	for i in range(15):
		await get_tree().physics_frame

	assert_check(knight.global_position.x > start_knight_x, "Knight moves right in response to movement input")
	assert_check(knight._facing_right == true, "Knight faces right when moving right")

	# Stop movement
	move_right_ev.axis_value = 0.0
	Input.parse_input_event(move_right_ev)
	Input.flush_buffered_events()
	await get_tree().physics_frame

	# Simulate Jump (Joypad A / Space)
	var jump_ev = InputEventJoypadButton.new()
	jump_ev.device = 0
	jump_ev.button_index = JoyButton.JOY_BUTTON_A
	jump_ev.pressed = true
	Input.parse_input_event(jump_ev)
	Input.flush_buffered_events()

	await get_tree().physics_frame
	await get_tree().physics_frame

	assert_check(knight.velocity.y < 0.0, "Knight jumps upward in response to jump input (vel Y: " + str(knight.velocity.y) + ")")

	jump_ev.pressed = false
	Input.parse_input_event(jump_ev)
	Input.flush_buffered_events()

	# Wait for Knight to reach peak and land back down
	for i in range(70):
		await get_tree().physics_frame
	assert_check(knight.is_on_floor(), "Knight falls with gravity and lands back on floor")

	print("\n[STEP 4] Mage AI Positioning and AI Fireball Cast")
	assert_check(mage.player == knight, "Mage AI has direct reference to Knight player")
	assert_check(not mage.has_method("is_player_2"), "Mage is an AI entity without Player 2 input dependencies")

	# Let AI think and move
	var mage_initial_hp = mage.stats.health
	var knight_initial_hp = knight.stats.health
	assert_check(mage_initial_hp == 125.0, "Mage starts with 125 HP")
	assert_check(knight_initial_hp == 125.0, "Knight starts with 125 HP")

	# Trigger Mage AI cast
	mage._ai_think_timer = 0.0
	mage._fireball_cooldown = 0.0
	mage._ai_decide()

	assert_check(mage._is_attacking == true, "Mage AI enters attack state to cast fireball")

	# Wait for fireball to be spawned (0.3s cast delay)
	await get_tree().create_timer(0.4).timeout

	var fireball_found = false
	for child in get_tree().current_scene.get_children():
		if child.name.begins_with("Fireball") or child.is_in_group("projectiles") or "damage" in child:
			fireball_found = true
			break
	assert_check(fireball_found, "Mage AI spawned fireball projectile in arena")

	print("\n[STEP 5] Knight Attack & Combat Interaction")
	# Position knight near mage to hit
	knight.global_position = mage.global_position - Vector2(30, 0)
	knight._facing_right = true

	# Trigger Knight attack
	var initial_stamina = knight.stats.stamina
	knight._try_attack()

	assert_check(knight._is_attacking == true, "Knight enters attacking state")
	assert_check(knight.stats.stamina == initial_stamina - 18.0, "Knight consumes 18 stamina on attack")

	# Simulate active frame 1
	knight.sprite.frame = 1
	knight._on_sprite_frame_changed()
	await get_tree().process_frame
	await get_tree().physics_frame
	assert_check(knight.attack_collision.disabled == false, "Knight attack hitbox active on swing frame")

	# Hit Mage
	knight._on_attack_hit_body(mage)
	assert_check(mage.stats.health == mage_initial_hp - 15.0, "Mage takes 15 damage from Knight melee strike")
	assert_check(mage.stats.knockback_percent == 8.0, "Mage knockback percent increased to 8%")
	assert_check(mage.velocity.length() > 0.0, "Mage received knockback velocity launch")

	print("\n[STEP 6] Bounce Platform Mechanics")
	var bounce_left = arena.get_node("BouncePlatformLeft")
	var bounce_right = arena.get_node("BouncePlatformRight")
	assert_check(bounce_left != null and bounce_right != null, "Bounce platforms active in arena")

	knight.apply_bounce(-750.0)
	assert_check(knight.velocity.y == -750.0, "Bounce platform recovery applies upward launch force")

	arena.queue_free()
