extends "res://scripts/enemies/enemy_base.gd"
## Mage boss: casts fireballs at the player.

const FIREBALL_SCENE = preload("res://scenes/effects/fireball.tscn")

var _fireball_cooldown: float = 0.0

func _ready() -> void:
	super._ready()
	_preferred_distance = 250.0

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _fireball_cooldown > 0.0:
		_fireball_cooldown -= delta

func _ai_decide() -> void:
	if not player or _is_dead or _is_attacking:
		return

	var dist = global_position.distance_to(player.global_position)

	# Cast fireball if in range and off cooldown
	if dist < 400.0 and dist > 80.0 and _fireball_cooldown <= 0.0:
		if stats.has_stamina(combat_config.mage_fireball_stamina):
			_cast_fireball()

func _cast_fireball() -> void:
	if not stats.use_stamina(combat_config.mage_fireball_stamina):
		return
	_is_attacking = true
	_fireball_cooldown = combat_config.mage_fireball_cooldown
	velocity.x = 0.0

	_play_anim("attack")

	# Spawn fireball after short cast delay
	await get_tree().create_timer(0.3).timeout
	if _is_dead or not is_instance_valid(self):
		_is_attacking = false
		return

	var fireball = FIREBALL_SCENE.instantiate()
	fireball.global_position = global_position + Vector2(40.0 if _facing_right else -40.0, -10.0)
	fireball.direction = Vector2(1 if _facing_right else -1, 0)
	fireball.speed = combat_config.mage_fireball_speed
	fireball.damage = combat_config.mage_fireball_damage
	fireball.knockback_add = combat_config.mage_fireball_knockback
	fireball.source = self
	get_tree().current_scene.add_child(fireball)

	await get_tree().create_timer(0.3).timeout
	_is_attacking = false
