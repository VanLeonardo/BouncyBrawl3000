extends CharacterBody2D
## Player knight controller: movement, jumping, attacking, knockback, platform drop-through.

signal attacked(attack_area: Area2D)
signal died()

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision_shape: CollisionShape2D = $CollisionShape
@onready var attack_area: Area2D = $AttackArea
@onready var attack_collision: CollisionShape2D = $AttackArea/AttackCollision
@onready var knockback_label: Label = $KnockbackLabel

var stats: FighterStats = FighterStats.new()
var combat_config: CombatConfig

# State
var _is_attacking: bool = false
var _attack_hit_list: Array = []  # tracks who we already hit this swing
var _facing_right: bool = true
var _knockback_velocity: Vector2 = Vector2.ZERO
var _is_knocked_back: bool = false
var _is_dead: bool = false

# Drop-through
var _drop_through_timer: float = 0.0
const DROP_THROUGH_DURATION: float = 0.25

func _ready() -> void:
	combat_config = GameManager.combat_config
	stats.reset()
	attack_collision.set_deferred("disabled", true)

	if knockback_label:
		knockback_label.top_level = true
		_update_knockback_label()

	stats.knockback_changed.connect(_on_knockback_changed)
	stats.fighter_died.connect(_on_fighter_died)

	GameManager.heal_tick.connect(_on_heal_tick)
	GameManager.player_stats = stats

	# Connect attack area and animation events
	attack_area.body_entered.connect(_on_attack_hit_body)
	sprite.frame_changed.connect(_on_sprite_frame_changed)
	sprite.animation_finished.connect(_on_sprite_animation_finished)

func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	if GameManager.fight_state != GameManager.FightState.FIGHTING:
		return

	stats.update_stamina_regen(delta)

	# Drop-through timer
	if _drop_through_timer > 0.0:
		_drop_through_timer -= delta
		if _drop_through_timer <= 0.0:
			_restore_platform_collision()

	# Gravity
	if not is_on_floor():
		velocity.y += combat_config.gravity * delta
	else:
		if velocity.y >= 0.0:
			_is_knocked_back = false
			_knockback_velocity = Vector2.ZERO

	# Knockback override
	if _is_knocked_back:
		velocity.x = lerpf(velocity.x, 0.0, 2.0 * delta)
		# Air control during knockback
		var input_dir = Input.get_axis("p1_left", "p1_right")
		velocity.x += input_dir * combat_config.move_speed * combat_config.air_control * delta * 60.0
	elif not _is_attacking:
		# Normal movement
		if is_on_floor():
			var input_dir = Input.get_axis("p1_left", "p1_right")
			velocity.x = input_dir * combat_config.move_speed

			# Jump or Drop through
			if Input.is_action_just_pressed("p1_jump"):
				if Input.is_action_pressed("p1_down"):
					_start_drop_through()
				else:
					velocity.y = combat_config.jump_force
					_play_anim("jump")
		else:
			# Air control while jumping/falling
			var input_dir = Input.get_axis("p1_left", "p1_right")
			velocity.x += input_dir * combat_config.move_speed * combat_config.air_control * delta * 60.0
			velocity.x = clampf(velocity.x, -combat_config.move_speed, combat_config.move_speed)

	# Attack (melee only, stamina gated)
	if Input.is_action_just_pressed("p1_attack") and not _is_attacking:
		_try_attack()

	# Facing direction
	var input_dir = Input.get_axis("p1_left", "p1_right")
	if input_dir != 0.0 and not _is_attacking:
		_facing_right = input_dir > 0.0
		sprite.flip_h = not _facing_right
		attack_area.position.x = absf(attack_area.position.x) * (1.0 if _facing_right else -1.0)

	# Animations (if not attacking)
	if not _is_attacking and not _is_dead:
		if is_on_floor():
			if absf(velocity.x) > 10.0:
				_play_anim("run")
			else:
				_play_anim("idle")
		else:
			if velocity.y < 0:
				_play_anim("jump")
			else:
				_play_anim("fall")

	move_and_slide()

	# Kill boundary check
	if global_position.y > combat_config.kill_boundary_y:
		_ring_out()

	# Update knockback label position
	if knockback_label:
		knockback_label.global_position = global_position + Vector2(-30, -65)

func _try_attack() -> void:
	if not stats.has_stamina(combat_config.knight_attack_stamina):
		return
	stats.use_stamina(combat_config.knight_attack_stamina)
	_is_attacking = true
	_attack_hit_list.clear()
	_play_anim("attack")
	# Active hitbox starts disabled; enabled during swing frames (1 & 2) via _on_sprite_frame_changed
	attack_collision.set_deferred("disabled", true)

func _on_sprite_frame_changed() -> void:
	if _is_attacking and sprite.animation == "attack":
		# Hitbox active only during swing window (frames 1 and 2)
		var is_active_frame = sprite.frame in [1, 2]
		attack_collision.set_deferred("disabled", not is_active_frame)
	elif not attack_collision.disabled:
		attack_collision.set_deferred("disabled", true)

func _on_sprite_animation_finished() -> void:
	if sprite.animation == "attack":
		attack_collision.set_deferred("disabled", true)
		_is_attacking = false
		_attack_hit_list.clear()

func _on_attack_hit_body(body: Node2D) -> void:
	if not _is_attacking:
		return
	if body == self:
		return
	if body in _attack_hit_list:
		return
	if not body.has_method("receive_hit"):
		return
	_attack_hit_list.append(body)

	var direction = Vector2(1 if body.global_position.x > global_position.x else -1, -0.3).normalized()
	body.receive_hit(combat_config.knight_attack_damage, combat_config.knight_knockback_add, direction, combat_config)

func receive_hit(damage: float, knockback_add: float, direction: Vector2, config: CombatConfig) -> void:
	if _is_dead:
		return
	stats.take_damage(damage)
	stats.add_knockback(knockback_add)

	# Apply knockback force
	var kb_force = config.get_knockback_force(stats.knockback_percent, direction)
	velocity = kb_force
	_is_knocked_back = true
	_knockback_velocity = kb_force

	# Interrupt current attack if in progress
	if _is_attacking:
		_is_attacking = false
		attack_collision.set_deferred("disabled", true)
		_attack_hit_list.clear()

	# Hit animation & flash
	if not _is_dead:
		_play_anim("hit")
		sprite.modulate = Color(1, 0.3, 0.3, 1)
		var flash_timer = get_tree().create_timer(0.15)
		await flash_timer.timeout
		if is_instance_valid(self) and sprite:
			sprite.modulate = Color.WHITE

func apply_bounce(force: float) -> void:
	velocity.y = force
	_is_knocked_back = false
	_play_anim("jump")

func _start_drop_through() -> void:
	set_collision_mask_value(2, false)  # Layer 2 = one-way platforms
	position.y += 4.0
	velocity.y = 120.0
	_drop_through_timer = DROP_THROUGH_DURATION

func _restore_platform_collision() -> void:
	set_collision_mask_value(2, true)

func _ring_out() -> void:
	_is_dead = true
	stats.take_damage(stats.health)
	died.emit()

func _on_fighter_died() -> void:
	_is_dead = true
	_play_anim("death")
	died.emit()

func _on_heal_tick() -> void:
	if not _is_dead:
		stats.heal(combat_config.heal_amount)

func _on_knockback_changed(percent: float) -> void:
	_update_knockback_label()

func _update_knockback_label() -> void:
	if knockback_label:
		knockback_label.text = str(int(stats.knockback_percent)) + "%"

func _play_anim(anim_name: String) -> void:
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
		if sprite.animation != anim_name:
			sprite.play(anim_name)
	elif sprite.sprite_frames and sprite.sprite_frames.has_animation("idle"):
		if sprite.animation != "idle":
			sprite.play("idle")

func reset_fighter() -> void:
	_is_dead = false
	_is_attacking = false
	_is_knocked_back = false
	_knockback_velocity = Vector2.ZERO
	_attack_hit_list.clear()
	attack_collision.set_deferred("disabled", true)
	stats.reset()
	sprite.modulate = Color.WHITE
	_update_knockback_label()
