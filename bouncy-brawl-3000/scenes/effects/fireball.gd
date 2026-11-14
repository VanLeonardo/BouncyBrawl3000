extends Area2D
## Fireball projectile for the Mage boss.

var direction: Vector2 = Vector2.RIGHT
var speed: float = 350.0
var damage: float = 12.0
var knockback_add: float = 6.0
var source: Node2D = null
var _lifetime: float = 3.0
var _has_hit: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Create visual
	var sprite = Sprite2D.new()
	sprite.name = "Visual"
	# Draw a fireball using a simple colored circle
	var circle = _create_fireball_visual()
	add_child(circle)

	# Collision shape
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 8.0
	col.shape = shape
	add_child(col)

	# Set collision
	collision_layer = 0
	collision_mask = 1  # Detect bodies on layer 1

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_lifetime -= delta
	if _lifetime <= 0.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if _has_hit:
		return
	if body == source:
		return
	if body.has_method("receive_hit"):
		_has_hit = true
		var dir = Vector2(direction.x, -0.3).normalized()
		body.receive_hit(damage, knockback_add, dir, GameManager.combat_config)
		_spawn_hit_effect()
		queue_free()

func _create_fireball_visual() -> Node2D:
	var node = Node2D.new()
	# Outer glow
	var outer = Polygon2D.new()
	outer.polygon = _circle_points(12.0, 8)
	outer.color = Color(1.0, 0.4, 0.0, 0.5)
	node.add_child(outer)
	# Inner core
	var inner = Polygon2D.new()
	inner.polygon = _circle_points(7.0, 8)
	inner.color = Color(1.0, 0.8, 0.2, 0.9)
	node.add_child(inner)
	return node

func _circle_points(radius: float, segments: int) -> PackedVector2Array:
	var pts = PackedVector2Array()
	for i in range(segments):
		var angle = TAU * i / segments
		pts.append(Vector2(cos(angle), sin(angle)) * radius)
	return pts

func _spawn_hit_effect() -> void:
	var effect = Node2D.new()
	var burst = Polygon2D.new()
	burst.polygon = _circle_points(16.0, 8)
	burst.color = Color(1.0, 0.6, 0.0, 0.8)
	effect.add_child(burst)
	effect.global_position = global_position
	get_tree().current_scene.add_child(effect)
	var tween = effect.create_tween()
	tween.tween_property(burst, "scale", Vector2(2.0, 2.0), 0.2)
	tween.parallel().tween_property(burst, "modulate:a", 0.0, 0.2)
	tween.tween_callback(effect.queue_free)
