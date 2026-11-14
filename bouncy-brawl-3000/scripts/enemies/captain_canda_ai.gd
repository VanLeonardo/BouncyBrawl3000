extends "res://scripts/enemies/enemy_base.gd"
## Captain Canda boss: throws a returning boomerang shield.

const SHIELD_SCENE = preload("res://scenes/effects/boomerang_shield.tscn")

var _shield_cooldown: float = 0.0
var _shield_out: bool = false

func _ready() -> void:
	super._ready()
	_preferred_distance = 200.0

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _shield_cooldown > 0.0:
		_shield_cooldown -= delta

func _ai_decide() -> void:
	if not player or _is_dead or _is_attacking or _shield_out:
		return

	var dist = global_position.distance_to(player.global_position)

	# Throw shield if in range and off cooldown
	if dist < 450.0 and dist > 60.0 and _shield_cooldown <= 0.0:
		if stats.has_stamina(combat_config.canda_shield_stamina):
			_throw_shield()

func _throw_shield() -> void:
	if not stats.use_stamina(combat_config.canda_shield_stamina):
		return
	_is_attacking = true
	_shield_out = true
	_shield_cooldown = combat_config.canda_shield_cooldown
	velocity.x = 0.0

	_play_anim("attack")

	await get_tree().create_timer(0.2).timeout
	if _is_dead or not is_instance_valid(self):
		_is_attacking = false
		_shield_out = false
		return

	var shield = SHIELD_SCENE.instantiate()
	shield.global_position = global_position + Vector2(30.0 if _facing_right else -30.0, -10.0)
	shield.target = player
	shield.owner_node = self
	shield.speed = combat_config.canda_shield_speed
	shield.damage = combat_config.canda_shield_damage
	shield.knockback_add = combat_config.canda_shield_knockback
	shield.returned.connect(_on_shield_returned)
	get_tree().current_scene.add_child(shield)

	_is_attacking = false

func _on_shield_returned() -> void:
	_shield_out = false
