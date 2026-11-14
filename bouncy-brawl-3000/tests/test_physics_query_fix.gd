extends Node

func _ready() -> void:
	print("========================================")
	print(" TESTING PHYSICS QUERY COLLISION FIX")
	print("========================================")
	
	var passed = [0]
	var failed = [0]
	
	var config = GameManager.combat_config
	
	# Instantiate player
	var player_scene = load("res://scenes/entities/player.tscn")
	var player = player_scene.instantiate()
	add_child(player)
	player.global_position = Vector2(500, 300)
	
	await get_tree().process_frame
	await get_tree().physics_frame
	
	var attack_col = player.get_node("AttackArea/AttackCollision")
	var sprite = player.get_node("Sprite")
	
	# TEST 1: Initial state
	print("\n[TEST 1] Initial Attack Hitbox State")
	assert_check(attack_col.disabled == true, "Attack collision is initially disabled", passed, failed)
	
	# TEST 2: Attack animation frame activation
	print("\n[TEST 2] Attack Animation Hitbox Timing")
	player._try_attack()
	assert_check(player._is_attacking == true, "Player is in attacking state", passed, failed)
	
	# Frame 0: windup -> hitbox should be disabled
	sprite.animation = "attack"
	sprite.frame = 0
	player._on_sprite_frame_changed()
	await get_tree().process_frame
	await get_tree().physics_frame
	assert_check(attack_col.disabled == true, "Hitbox disabled during windup (frame 0)", passed, failed)
	
	# Frame 1: active swing -> hitbox should be enabled
	sprite.frame = 1
	player._on_sprite_frame_changed()
	await get_tree().process_frame
	await get_tree().physics_frame
	assert_check(attack_col.disabled == false, "Hitbox enabled during active swing (frame 1)", passed, failed)
	
	# Frame 2: active swing -> hitbox should be enabled
	sprite.frame = 2
	player._on_sprite_frame_changed()
	await get_tree().process_frame
	await get_tree().physics_frame
	assert_check(attack_col.disabled == false, "Hitbox enabled during active swing (frame 2)", passed, failed)
	
	# Frame 3: recovery -> hitbox should be disabled
	sprite.frame = 3
	player._on_sprite_frame_changed()
	await get_tree().process_frame
	await get_tree().physics_frame
	assert_check(attack_col.disabled == true, "Hitbox disabled during recovery (frame 3)", passed, failed)
	
	# Finish attack
	player._on_sprite_animation_finished()
	await get_tree().process_frame
	await get_tree().physics_frame
	assert_check(player._is_attacking == false, "Attack finished, _is_attacking is false", passed, failed)
	assert_check(attack_col.disabled == true, "Hitbox remains disabled after attack finishes", passed, failed)
	
	# TEST 3: Shield hitting player during physics query flush
	print("\n[TEST 3] Boomerang Shield Hit During Physics Callback")
	var mock_owner = Node2D.new()
	mock_owner.global_position = Vector2(100, 300)
	add_child(mock_owner)
	
	var shield_scene = load("res://scenes/effects/boomerang_shield.tscn")
	var shield = shield_scene.instantiate()
	shield.owner_node = mock_owner
	shield.target = player
	add_child(shield)
	shield.global_position = Vector2(400, 300)
	
	# Start attack on player right before shield hit to test hitstun attack cancellation
	player._try_attack()
	sprite.animation = "attack"
	sprite.frame = 1
	player._on_sprite_frame_changed()
	await get_tree().process_frame
	await get_tree().physics_frame
	assert_check(attack_col.disabled == false, "Player attacking with active hitbox", passed, failed)
	
	# Simulate shield entering player body (as happens during physics flush)
	var hp_before = player.stats.health
	shield._on_body_entered(player)
	await get_tree().process_frame
	await get_tree().physics_frame
	
	assert_check(player.stats.health == hp_before - shield.damage, "Player received shield damage (" + str(shield.damage) + " HP)", passed, failed)
	assert_check(player._is_attacking == false, "Shield hit interrupted player attack", passed, failed)
	assert_check(attack_col.disabled == true, "Attack hitbox safely disabled after hitstun", passed, failed)
	assert_check(player._is_knocked_back == true, "Player knocked back by shield hit", passed, failed)
	
	# TEST 4: Multiple shield passes / hits
	print("\n[TEST 4] Shield Repeated Hit Cooldown & Safety")
	var hp_during_cooldown = player.stats.health
	shield._on_body_entered(player)
	assert_check(player.stats.health == hp_during_cooldown, "Repeated hit within cooldown is safely ignored", passed, failed)
	
	# Cleanup
	player.queue_free()
	shield.queue_free()
	mock_owner.queue_free()
	
	print("\n========================================")
	print(" FINAL RESULTS: ", passed[0], " PASSED, ", failed[0], " FAILED")
	print("========================================")
	
	if failed[0] == 0:
		print(">>> ALL PHYSICS QUERY FIX TESTS PASSED! <<<")
	else:
		print(">>> TESTS FAILED! <<<")
	
	get_tree().quit()

func assert_check(condition: bool, description: String, passed: Array, failed: Array) -> void:
	if condition:
		print("  [PASS] ", description)
		passed[0] += 1
	else:
		print("  [FAIL] ", description)
		failed[0] += 1
