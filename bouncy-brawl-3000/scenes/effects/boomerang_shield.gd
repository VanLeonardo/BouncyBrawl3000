extends Area2D
## Boomerang shield for Captain Canda. Travels toward player, then returns.

signal returned()

var target: Node2D = null
var owner_node: Node2D = null
var speed: float = 400.0
var damage: float = 14.0
var knockback_add: float = 7.0

var _phase: int = 0  # 0=going to target, 1=returning
var _lifetime: float = 5.0
var _has_hit_going: bool = false
var _has_hit_returning: bool = false
var _target_pos: Vector2 = Vector2.ZERO
var _hit_cooldown_bodies: Dictionary = {}

func _ready() -> void:
	body_entered.connect(_on_body_entered)

	if target:
		_target_pos = target.global_position

	collision_layer = 0
	collision_mask = 1

func _physics_process(delta: float) -> void:
	_lifetime -= delta
	if _lifetime <= 0.0:
		returned.emit()
		queue_free()
		return

	# Update hit cooldowns
	for b in _hit_cooldown_bodies.keys():
		_hit_cooldown_bodies[b] -= delta
		if _hit_cooldown_bodies[b] <= 0.0:
			_hit_cooldown_bodies.erase(b)

	# Rotate for visual spinning effect in flight
	rotation += 12.0 * delta

	if _phase == 0:
		# Moving toward target position
		var dir = (_target_pos - global_position).normalized()
		position += dir * speed * delta
		if global_position.distance_to(_target_pos) < 20.0:
			_phase = 1
	else:
		# Returning to owner
		if is_instance_valid(owner_node):
			var dir = (owner_node.global_position - global_position).normalized()
			position += dir * speed * delta
			if global_position.distance_to(owner_node.global_position) < 30.0:
				returned.emit()
				queue_free()
		else:
			returned.emit()
			queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == owner_node:
		return
	if not body.has_method("receive_hit"):
		return
	if _hit_cooldown_bodies.has(body):
		return

	if _phase == 0 and _has_hit_going:
		return
	if _phase == 1 and _has_hit_returning:
		return

	if _phase == 0:
		_has_hit_going = true
	else:
		_has_hit_returning = true

	_hit_cooldown_bodies[body] = 0.4

	var dir_x = sign(body.global_position.x - global_position.x)
	if dir_x == 0.0:
		dir_x = 1.0
	var dir = Vector2(dir_x, -0.3).normalized()
	body.receive_hit(damage, knockback_add, dir, GameManager.combat_config)
