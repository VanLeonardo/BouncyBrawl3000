extends Area2D
## Bounce platform: launches fighters upward when they land on it.

@export var bounce_force: float = -750.0

func _ready() -> void:
	if GameManager and GameManager.combat_config:
		bounce_force = GameManager.combat_config.bounce_force
	body_entered.connect(_on_body_entered)

func _physics_process(_delta: float) -> void:
	# Continuous check for any fighter touching while moving downward
	for body in get_overlapping_bodies():
		if body.has_method("apply_bounce") and body.velocity.y > 0:
			_trigger_bounce(body)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("apply_bounce"):
		# Bounce if moving downward
		if body.velocity.y >= 0:
			_trigger_bounce(body)

func _trigger_bounce(body: Node2D) -> void:
	body.apply_bounce(bounce_force)
	_flash_effect()

func _flash_effect() -> void:
	var tween = create_tween()
	modulate = Color(1.8, 1.8, 2.5, 1.0)
	tween.tween_property(self, "modulate", Color.WHITE, 0.35)
