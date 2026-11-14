extends Node

func _ready() -> void:
	print("========================================")
	print(" RUNNING MILESTONE 1 AUTOMATED TESTS (IN-ENGINE)")
	print("========================================")
	
	var passed = [0]
	var failed = [0]
	
	# Verify Autoload
	print("\n[TEST 1] Autoload GameManager")
	assert_check(GameManager != null, "Autoload GameManager is initialized", passed, failed)
	assert_check(GameManager.combat_config != null, "CombatConfig is loaded in GameManager", passed, failed)
	
	# TEST 2: FighterStats & CombatConfig
	print("\n[TEST 2] FighterStats & CombatConfig")
	var stats = FighterStats.new()
	var config = GameManager.combat_config
	stats.reset()
	
	assert_check(stats.health == 125.0, "Initial HP is 125", passed, failed)
	assert_check(stats.stamina == 100.0, "Initial Stamina is 100", passed, failed)
	assert_check(stats.knockback_percent == 0.0, "Initial Knockback is 0%", passed, failed)
	
	stats.take_damage(config.knight_attack_damage)
	assert_check(stats.health == 110.0, "HP after 15 dmg is 110", passed, failed)
	
	var attack_ok = stats.use_stamina(config.knight_attack_stamina)
	assert_check(attack_ok == true, "Stamina used successfully", passed, failed)
	assert_check(stats.stamina == 82.0, "Stamina after 18 cost is 82", passed, failed)
	
	stats.add_knockback(config.knight_knockback_add)
	assert_check(stats.knockback_percent == 8.0, "Knockback % after hit is 8%", passed, failed)
	
	stats.heal(config.heal_amount)
	assert_check(stats.health == 125.0, "Heal restores 15 HP to max 125", passed, failed)
	
	stats.heal(100.0)
	assert_check(stats.health == 125.0, "Heal does not exceed max HP 125", passed, failed)
	
	# TEST 3: Scene Loading & Resource Integrity
	print("\n[TEST 3] Scene Loading & Integrity")
	var scenes_to_test = [
		"res://scenes/ui/title_screen.tscn",
		"res://scenes/campaign/arena.tscn",
		"res://scenes/entities/player.tscn",
		"res://scenes/enemies/mage.tscn",
		"res://scenes/enemies/captain_canda.tscn",
		"res://scenes/enemies/shoebum.tscn",
		"res://scenes/effects/fireball.tscn",
		"res://scenes/effects/boomerang_shield.tscn",
		"res://scenes/ui/battle_hud.tscn",
		"res://scenes/ui/pause_menu.tscn",
		"res://scenes/ui/fight_result.tscn"
	]
	
	for s_path in scenes_to_test:
		var packed = load(s_path)
		assert_check(packed != null, "Scene loads: " + s_path, passed, failed)
	
	# TEST 4: Player Controller Components
	print("\n[TEST 4] Player Node Components")
	var player_packed = load("res://scenes/entities/player.tscn")
	var player = player_packed.instantiate()
	add_child(player)
	
	var sprite = player.get_node("Sprite")
	assert_check(sprite != null, "Player has Sprite", passed, failed)
	assert_check(sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Player sprite is pixelated (Nearest filter)", passed, failed)
	
	var atk_area = player.get_node("AttackArea")
	var atk_col = player.get_node("AttackArea/AttackCollision")
	assert_check(atk_area != null, "Player has AttackArea", passed, failed)
	assert_check(atk_col != null, "Player has AttackCollision", passed, failed)
	assert_check(atk_col.disabled == true, "Attack hitbox initially disabled", passed, failed)
	assert_check(player.collision_mask == 3, "Player collides with Layer 1 + Layer 2", passed, failed)
	
	var kb_label = player.get_node("KnockbackLabel")
	assert_check(kb_label != null, "Player has KnockbackLabel", passed, failed)
	assert_check(kb_label.top_level == true, "KnockbackLabel is top_level", passed, failed)
	
	# TEST 5: Drop-Through Mechanic
	print("\n[TEST 5] One-Way Drop-Through")
	player._start_drop_through()
	assert_check(player.get_collision_mask_value(2) == false, "Layer 2 mask disabled during drop-through", passed, failed)
	assert_check(player.velocity.y > 0, "Downward velocity applied on drop-through", passed, failed)
	player._restore_platform_collision()
	assert_check(player.get_collision_mask_value(2) == true, "Layer 2 mask restored after drop-through", passed, failed)
	
	# TEST 6: Bounce Platform Recovery
	print("\n[TEST 6] Bounce Platform Recovery")
	player.apply_bounce(config.bounce_force)
	assert_check(player.velocity.y == config.bounce_force, "Bounce applies upward force " + str(config.bounce_force), passed, failed)
	
	# TEST 7: Knockback & Hit Feedback
	print("\n[TEST 7] Knockback & Damage Processing")
	var initial_hp = player.stats.health
	player.receive_hit(15.0, 8.0, Vector2(1, -0.3).normalized(), config)
	assert_check(player.stats.health == initial_hp - 15.0, "Player takes 15 damage", passed, failed)
	assert_check(player.stats.knockback_percent == 8.0, "Player knockback % increased to 8%", passed, failed)
	assert_check(player.velocity.x > 0, "Knockback launches player horizontally", passed, failed)
	assert_check(player.velocity.y < 0, "Knockback launches player upward", passed, failed)
	assert_check(kb_label.text == "8%", "KnockbackLabel displays 8%", passed, failed)
	
	# TEST 8: HUD Setup & Updates
	print("\n[TEST 8] HUD Updates")
	var hud_packed = load("res://scenes/ui/battle_hud.tscn")
	var hud = hud_packed.instantiate()
	add_child(hud)
	
	var enemy_stats = FighterStats.new()
	enemy_stats.reset()
	hud.setup(player.stats, enemy_stats, "Mage")
	
	assert_check(hud.player_name_label.text == "Knight", "HUD Player Name is Knight", passed, failed)
	assert_check(hud.enemy_name_label.text == "Mage", "HUD Enemy Name is Mage", passed, failed)
	assert_check(hud.player_health_bar.value == player.stats.health, "HUD Player HP matches", passed, failed)
	assert_check(hud.enemy_health_bar.value == 125.0, "HUD Enemy HP matches", passed, failed)
	
	# TEST 9: Periodic Healing Tick
	print("\n[TEST 9] Periodic Healing Tick")
	var hp_before_heal = player.stats.health
	GameManager.heal_tick.emit()
	assert_check(player.stats.health == hp_before_heal + config.heal_amount, "Heal tick heals player by 15 HP", passed, failed)
	
	# TEST 10: Arena Scenery & Bounce Platforms
	print("\n[TEST 10] Arena Setup & Recovery Platforms")
	var arena_packed = load("res://scenes/campaign/arena.tscn")
	var arena = arena_packed.instantiate()
	add_child(arena)
	
	var bounce_left = arena.get_node_or_null("BouncePlatformLeft")
	var bounce_right = arena.get_node_or_null("BouncePlatformRight")
	assert_check(bounce_left != null, "BouncePlatformLeft exists in Arena", passed, failed)
	assert_check(bounce_right != null, "BouncePlatformRight exists in Arena", passed, failed)
	assert_check(bounce_left.global_position.x == 160.0, "BouncePlatformLeft X is 160 (exact lower left platform position)", passed, failed)
	assert_check(bounce_right.global_position.x == 960.0, "BouncePlatformRight X is 960 (exact lower right platform position)", passed, failed)
	assert_check(bounce_left.bounce_force == config.bounce_force, "BouncePlatformLeft force matches config", passed, failed)
	
	# Cleanup
	player.queue_free()
	hud.queue_free()
	arena.queue_free()
	
	print("\n========================================")
	print(" FINAL RESULTS: ", passed[0], " PASSED, ", failed[0], " FAILED")
	print("========================================")
	
	if failed[0] == 0:
		print(">>> ALL MILESTONE 1 TESTS PASSED! <<<")
	else:
		print(">>> MILESTONE 1 VERIFICATION FAILED! <<<")
	
	get_tree().quit()

func assert_check(condition: bool, description: String, passed: Array, failed: Array) -> void:
	if condition:
		print("  [PASS] ", description)
		passed[0] += 1
	else:
		print("  [FAIL] ", description)
		failed[0] += 1
