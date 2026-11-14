extends Node
## Automated tests verifying asset integration and UI polish.

func _ready() -> void:
	print("========================================")
	print(" RUNNING ASSET INTEGRATION & UI TESTS")
	print("========================================")

	var passed = [0]
	var failed = [0]

	# TEST 1: Fireball Animated Sprite
	print("\n[TEST 1] Fireball Asset & Animation")
	var fb_packed = load("res://scenes/effects/fireball.tscn")
	assert_check(fb_packed != null, "Fireball scene loads", passed, failed)
	var fb = fb_packed.instantiate()
	add_child(fb)
	var fb_sprite = fb.get_node_or_null("Sprite")
	assert_check(fb_sprite != null, "Fireball has Sprite node", passed, failed)
	assert_check(fb_sprite is AnimatedSprite2D, "Fireball sprite is AnimatedSprite2D", passed, failed)
	assert_check(fb_sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Fireball sprite uses Nearest pixel filter", passed, failed)
	assert_check(fb_sprite.sprite_frames.get_frame_count("default") == 5, "Fireball default animation has 5 frames (FB001-FB005)", passed, failed)
	assert_check(fb_sprite.sprite_frames.get_animation_speed("default") == 12.0, "Fireball animation speed is 12 FPS", passed, failed)

	# Test orientation
	fb.direction = Vector2(-1, 0)
	assert_check(fb_sprite.flip_h == true, "Fireball flips horizontally when moving left", passed, failed)
	fb.direction = Vector2(1, 0)
	assert_check(fb_sprite.flip_h == false, "Fireball faces right when moving right", passed, failed)
	fb.queue_free()

	# TEST 2: Captain Canda & Boomerang Shield
	print("\n[TEST 2] Captain Canda & Shield Assets")
	var shield_packed = load("res://scenes/effects/boomerang_shield.tscn")
	assert_check(shield_packed != null, "BoomerangShield scene loads", passed, failed)
	var shield = shield_packed.instantiate()
	add_child(shield)
	var shield_sprite = shield.get_node_or_null("Sprite2D")
	assert_check(shield_sprite != null, "BoomerangShield has Sprite2D node", passed, failed)
	assert_check(shield_sprite.texture != null, "BoomerangShield uses Shield.png texture", passed, failed)
	assert_check(shield_sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Shield uses Nearest pixel filter", passed, failed)

	var rot_before = shield.rotation
	shield._physics_process(0.1)
	assert_check(shield.rotation > rot_before, "Shield continuously spins during physics process", passed, failed)
	shield.queue_free()

	var canda_packed = load("res://scenes/enemies/captain_canda.tscn")
	assert_check(canda_packed != null, "Captain Canda scene loads", passed, failed)
	var canda = canda_packed.instantiate()
	add_child(canda)
	var canda_sprite = canda.get_node_or_null("Sprite")
	assert_check(canda_sprite != null, "Captain Canda has Sprite node", passed, failed)
	assert_check(canda_sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Captain Canda uses Nearest pixel filter", passed, failed)
	assert_check(canda_sprite.sprite_frames.has_animation("idle"), "Captain Canda has idle animation", passed, failed)
	assert_check(canda_sprite.sprite_frames.has_animation("run"), "Captain Canda has run animation", passed, failed)
	assert_check(canda_sprite.sprite_frames.get_frame_count("run") == 4, "Captain Canda run has 4 looping frames", passed, failed)
	assert_check(canda_sprite.sprite_frames.get_animation_loop("run") == true, "Captain Canda run animation loops", passed, failed)
	assert_check(canda_sprite.sprite_frames.has_animation("attack"), "Captain Canda has attack/throw animation", passed, failed)
	assert_check(canda_sprite.sprite_frames.get_frame_count("attack") == 3, "Captain Canda attack has 3 throw frames", passed, failed)
	canda.queue_free()

	# TEST 3: Shoebum Visuals & Animations
	print("\n[TEST 3] Shoebum Assets & Animations")
	var shoebum_packed = load("res://scenes/enemies/shoebum.tscn")
	assert_check(shoebum_packed != null, "Shoebum scene loads", passed, failed)
	var shoebum = shoebum_packed.instantiate()
	add_child(shoebum)
	var sb_sprite = shoebum.get_node_or_null("Sprite")
	assert_check(sb_sprite != null, "Shoebum has Sprite node", passed, failed)
	assert_check(sb_sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Shoebum uses Nearest pixel filter", passed, failed)
	assert_check(sb_sprite.sprite_frames.has_animation("idle"), "Shoebum has idle animation", passed, failed)
	assert_check(sb_sprite.sprite_frames.has_animation("run"), "Shoebum has run animation", passed, failed)
	assert_check(sb_sprite.sprite_frames.get_frame_count("run") == 2, "Shoebum run has 2 looping frames", passed, failed)
	assert_check(sb_sprite.sprite_frames.get_animation_loop("run") == true, "Shoebum run animation loops", passed, failed)
	assert_check(sb_sprite.sprite_frames.has_animation("attack"), "Shoebum has attack animation", passed, failed)
	assert_check(shoebum.get_node_or_null("SlapArea") != null, "Shoebum has SlapArea for melee strike", passed, failed)
	shoebum.queue_free()

	# TEST 4: Battle HUD Styling & Functional Integrity
	print("\n[TEST 4] Battle HUD Integration")
	var hud_packed = load("res://scenes/ui/battle_hud.tscn")
	assert_check(hud_packed != null, "Battle HUD scene loads", passed, failed)
	var hud = hud_packed.instantiate()
	add_child(hud)

	var p_stats = FighterStats.new()
	var e_stats = FighterStats.new()
	p_stats.reset()
	e_stats.reset()
	hud.setup(p_stats, e_stats, "Captain Canda")

	assert_check(hud.player_name_label.text == "Knight", "HUD Player Name is Knight", passed, failed)
	assert_check(hud.enemy_name_label.text == "Captain Canda", "HUD Enemy Name is Captain Canda", passed, failed)
	assert_check(hud.player_health_bar.value == 125.0, "HUD Player HP value initialized to 125", passed, failed)
	assert_check(hud.player_stamina_bar.value == 100.0, "HUD Player Stamina initialized to 100", passed, failed)
	assert_check(hud.get_node_or_null("PlayerPanel") != null, "HUD has PlayerPanel frame", passed, failed)
	assert_check(hud.get_node_or_null("EnemyPanel") != null, "HUD has EnemyPanel frame", passed, failed)

	p_stats.take_damage(25.0)
	assert_check(hud.player_health_bar.value == 100.0, "HUD Player HP bar dynamically updates to 100", passed, failed)
	assert_check(hud.player_health_value.text == "100 / 125", "HUD Player HP text dynamically updates", passed, failed)
	hud.queue_free()

	# TEST 5: Title Screen Visual Hierarchy & Navigation
	print("\n[TEST 5] Title Screen Hierarchy")
	var title_packed = load("res://scenes/ui/title_screen.tscn")
	assert_check(title_packed != null, "Title Screen scene loads", passed, failed)
	var title = title_packed.instantiate()
	add_child(title)

	assert_check(title.play_button != null, "Title Screen has PlayButton", passed, failed)
	assert_check(title.controls_button != null, "Title Screen has ControlsButton", passed, failed)
	assert_check(title.quit_button != null, "Title Screen has QuitButton", passed, failed)
	assert_check(title.controls_modal != null, "Title Screen has ControlsModal", passed, failed)
	assert_check(title.controls_modal.visible == false, "ControlsModal initially hidden", passed, failed)

	title.controls_button.emit_signal("pressed")
	assert_check(title.controls_modal.visible == true, "ControlsModal opens on ControlsButton click", passed, failed)

	title.close_controls_button.emit_signal("pressed")
	assert_check(title.controls_modal.visible == false, "ControlsModal closes on CloseButton click", passed, failed)

	assert_check(title.get_node_or_null("KnightShowcase") != null, "Title Screen features KnightShowcase", passed, failed)
	assert_check(title.get_node_or_null("BossShowcase") != null, "Title Screen features BossShowcase", passed, failed)
	title.queue_free()

	print("\n========================================")
	print(" ASSET INTEGRATION RESULTS: ", passed[0], " PASSED, ", failed[0], " FAILED")
	print("========================================")

	if failed[0] == 0:
		print(">>> ALL ASSET INTEGRATION TESTS PASSED! <<<")
	else:
		print(">>> ASSET INTEGRATION TESTS FAILED! <<<")

	get_tree().quit()

func assert_check(condition: bool, description: String, passed: Array, failed: Array) -> void:
	if condition:
		print("  [PASS] ", description)
		passed[0] += 1
	else:
		print("  [FAIL] ", description)
		failed[0] += 1
