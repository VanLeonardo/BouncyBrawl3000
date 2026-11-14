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

func _ready() -> void:
	body_entered.connect(_on_body_entered)

	if target:
		_target_pos = target.global_position

	# Create visual - shield with maple leaf
	var visual = _create_shield_visual()
	add_child(visual)

	# Collision
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 12.0
	col.shape = shape
	add_child(col)

	collision_layer = 0
	collision_mask = 1

func _physics_process(delta: float) -> void:
	_lifetime -= delta
	if _lifetime <= 0.0:
		returned.emit()
		queue_free()
		return

	# Rotate for visual effect
	rotation += 10.0 * delta

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

	if _phase == 0 and _has_hit_going:
		return
	if _phase == 1 and _has_hit_returning:
		return

	if _phase == 0:
		_has_hit_going = true
	else:
		_has_hit_returning = true

	var dir = Vector2(sign(body.global_position.x - global_position.x), -0.3).normalized()
	body.receive_hit(damage, knockback_add, dir, GameManager.combat_config)

func _create_shield_visual() -> Node2D:
	var node = Node2D.new()

	# Shield circle
	var shield = Polygon2D.new()
	shield.polygon = _circle_points(14.0, 12)
	shield.color = Color(0.7, 0.7, 0.8, 1.0)
	node.add_child(shield)

	# Maple leaf (red) - simplified
	var leaf = Polygon2D.new()
	leaf.polygon = PackedVector2Array([
		Vector2(0, -8),
		Vector2(-3, -4), Vector2(-7, -5),
		Vector2(-4, -1), Vector2(-6, 3),
		Vector2(-2, 1), Vector2(0, 5),
		Vector2(2, 1), Vector2(6, 3),
		Vector2(4, -1), Vector2(7, -5),
		Vector2(3, -4)
	])
	leaf.color = Color(0.9, 0.1, 0.1, 1.0)
	node.add_child(leaf)

	return node

func _circle_points(radius: float, segments: int) -> PackedVector2Array:
	var pts = PackedVector2Array()
	for i in range(segments):
		var angle = TAU * i / segments
		pts.append(Vector2(cos(angle), sin(angle)) * radius)
	return pts
