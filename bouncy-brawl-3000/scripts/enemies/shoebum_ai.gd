extends "res://scripts/enemies/enemy_base.gd"
## Shoebum boss: close-range slap + ground stomp with multi-pulse launch.

var _slap_cooldown: float = 0.0
var _stomp_cooldown: float = 0.0
var _stomp_active: bool = false

@onready var slap_area: Area2D = $SlapArea
@onready var slap_collision: CollisionShape2D = $SlapArea/SlapCollision

var _slap_hit_list: Array = []

func _ready() -> void:
	super._ready()
	_preferred_distance = 80.0  # Wants to be close
	if slap_collision:
		slap_collision.set_deferred("disabled", true)
	if slap_area:
		slap_area.body_entered.connect(_on_slap_hit)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _slap_cooldown > 0.0:
		_slap_cooldown -= delta
	if _stomp_cooldown > 0.0:
		_stomp_cooldown -= delta

func _ai_decide() -> void:
	if not player or _is_dead or _is_attacking or _stomp_active:
		return

	var dist = global_position.distance_to(player.global_position)

	# Stomp if player is on the ground nearby and cooldown is done
	if dist < 300.0 and _stomp_cooldown <= 0.0 and is_on_floor():
		if stats.has_stamina(combat_config.shoebum_stomp_stamina):
			_ground_stomp()
			return

	# Slap if close enough
	if dist < 100.0 and _slap_cooldown <= 0.0:
		if stats.has_stamina(combat_config.shoebum_slap_stamina):
			_slap_attack()

func _slap_attack() -> void:
	if not stats.use_stamina(combat_config.shoebum_slap_stamina):
		return
	_is_attacking = true
	_slap_cooldown = combat_config.shoebum_slap_cooldown
	_slap_hit_list.clear()
	velocity.x = 0.0

	# Enable slap hitbox
	if slap_collision:
		slap_collision.set_deferred("disabled", false)
		slap_area.position.x = absf(slap_area.position.x) * (1.0 if _facing_right else -1.0)

	_play_anim("attack")

	await get_tree().create_timer(0.4).timeout
	if slap_collision:
		slap_collision.set_deferred("disabled", true)
	_is_attacking = false
	_slap_hit_list.clear()

func _on_slap_hit(body: Node2D) -> void:
	if not _is_attacking:
		return
	if body == self or body in _slap_hit_list:
		return
	if not body.has_method("receive_hit"):
		return
	_slap_hit_list.append(body)

	var direction = Vector2(1 if body.global_position.x > global_position.x else -1, -0.3).normalized()
	body.receive_hit(combat_config.shoebum_slap_damage, combat_config.shoebum_slap_knockback, direction, combat_config)

func _ground_stomp() -> void:
	if not stats.use_stamina(combat_config.shoebum_stomp_stamina):
		return
	_is_attacking = true
	_stomp_active = true
	_stomp_cooldown = combat_config.shoebum_stomp_cooldown
	velocity.x = 0.0

	_play_anim("attack")

	# Multi-pulse stomp
	for i in range(combat_config.shoebum_stomp_pulses):
		await get_tree().create_timer(combat_config.shoebum_stomp_pulse_interval).timeout
		if _is_dead or not is_instance_valid(self):
			break
		_emit_stomp_pulse(i)

	_is_attacking = false
	_stomp_active = false

func _emit_stomp_pulse(pulse_index: int) -> void:
	if not player:
		return

	# Create visual shockwave
	var wave = _create_shockwave()
	get_tree().current_scene.add_child(wave)
	wave.global_position = Vector2(global_position.x, global_position.y)

	# Check if player is on the floor and within range
	var dist_x = absf(player.global_position.x - global_position.x)
	if dist_x < 250.0 and player.is_on_floor():
		var direction = Vector2(0, -1)
		player.receive_hit(combat_config.shoebum_stomp_damage, combat_config.shoebum_stomp_knockback, direction, combat_config)
		player.velocity.y = combat_config.shoebum_stomp_launch_force

func _create_shockwave() -> Node2D:
	var wave = Node2D.new()
	var line = Line2D.new()
	line.width = 3.0
	line.default_color = Color(1.0, 0.5, 0.0, 0.8)
	line.add_point(Vector2(-200, 0))
	line.add_point(Vector2(-100, -15))
	line.add_point(Vector2(0, 0))
	line.add_point(Vector2(100, -15))
	line.add_point(Vector2(200, 0))
	wave.add_child(line)

	# Fade and free
	var tween = wave.create_tween()
	tween.tween_property(line, "modulate:a", 0.0, 0.5)
	tween.tween_callback(wave.queue_free)

	return wave
