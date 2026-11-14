extends CharacterBody2D
## Base enemy AI controller. Extended by specific boss scripts.

signal died()

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision_shape: CollisionShape2D = $CollisionShape
@onready var knockback_label: Label = $KnockbackLabel

var stats: FighterStats = FighterStats.new()
var combat_config: CombatConfig
var player: CharacterBody2D = null

# State
var _is_attacking: bool = false
var _facing_right: bool = false
var _is_knocked_back: bool = false
var _knockback_velocity: Vector2 = Vector2.ZERO
var _is_dead: bool = false

# AI
var _preferred_distance: float = 200.0  # How far to stay from player
var _ai_think_timer: float = 0.0
var _ai_think_interval: float = 0.3  # Seconds between AI decisions

# Platform boundary safety
const MAIN_PLATFORM_LEFT: float = 360.0
const MAIN_PLATFORM_RIGHT: float = 710.0

func _ready() -> void:
	combat_config = GameManager.combat_config
	stats.reset()
	collision_mask = 3  # Collide with both Layer 1 and Layer 2 platforms

	if knockback_label:
		knockback_label.top_level = true
		_update_knockback_label()

	stats.knockback_changed.connect(_on_knockback_changed)
	stats.fighter_died.connect(_on_fighter_died)
	GameManager.heal_tick.connect(_on_heal_tick)
	GameManager.enemy_stats = stats

func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	if GameManager.fight_state != GameManager.FightState.FIGHTING:
		return

	stats.update_stamina_regen(delta)

	# Gravity
	if not is_on_floor():
		velocity.y += combat_config.gravity * delta
	else:
		if velocity.y >= 0.0:
			_is_knocked_back = false
			_knockback_velocity = Vector2.ZERO

	# AI behavior
	if _is_knocked_back:
		velocity.x = lerpf(velocity.x, 0.0, 2.0 * delta)
		# AI air control steering toward center platform
		var dir_to_center = sign(536.0 - global_position.x)
		velocity.x += dir_to_center * combat_config.move_speed * combat_config.air_control * delta * 60.0
	elif not _is_attacking:
		_ai_think_timer -= delta
		if _ai_think_timer <= 0.0:
			_ai_think_timer = _ai_think_interval
			_ai_decide()
		_ai_move(delta)

	# Facing
	if player and not _is_attacking:
		_facing_right = player.global_position.x > global_position.x
		sprite.flip_h = not _facing_right

	# Animations
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

	# Kill boundary
	if global_position.y > combat_config.kill_boundary_y:
		_ring_out()

	# Update knockback label position
	if knockback_label:
		knockback_label.global_position = global_position + Vector2(-30, -65)

## Override in subclass to customize AI decisions
func _ai_decide() -> void:
	pass

## Override in subclass to customize movement
func _ai_move(delta: float) -> void:
	if not player:
		return
	var dist = global_position.distance_to(player.global_position)
	var dir_to_player = sign(player.global_position.x - global_position.x)

	if dist > _preferred_distance + 30.0:
		velocity.x = dir_to_player * combat_config.move_speed * 0.7
	elif dist < _preferred_distance - 30.0:
		velocity.x = -dir_to_player * combat_config.move_speed * 0.5
	else:
		velocity.x = lerpf(velocity.x, 0.0, 5.0 * delta)

	# Ledge safety on main platform
	if is_on_floor() and global_position.y > 380.0 and global_position.y < 460.0:
		if global_position.x <= MAIN_PLATFORM_LEFT and velocity.x < 0.0:
			velocity.x = 0.0
		elif global_position.x >= MAIN_PLATFORM_RIGHT and velocity.x > 0.0:
			velocity.x = 0.0

func receive_hit(damage: float, knockback_add: float, direction: Vector2, config: CombatConfig) -> void:
	if _is_dead:
		return
	stats.take_damage(damage)
	stats.add_knockback(knockback_add)

	var kb_force = config.get_knockback_force(stats.knockback_percent, direction)
	velocity = kb_force
	_is_knocked_back = true
	_knockback_velocity = kb_force

	# Hit flash
	if not _is_dead:
		_play_anim("hit")
		sprite.modulate = Color(1, 0.3, 0.3, 1)
		var timer = get_tree().create_timer(0.15)
		await timer.timeout
		if is_instance_valid(self) and sprite:
			sprite.modulate = Color.WHITE

func apply_bounce(force: float) -> void:
	velocity.y = force
	_is_knocked_back = false
	_play_anim("jump")

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
	stats.reset()
	sprite.modulate = Color.WHITE
	_update_knockback_label()
