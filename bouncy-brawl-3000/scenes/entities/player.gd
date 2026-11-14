extends CharacterBody2D

@export var prefix: String = "p1_"
@export var opponent: CharacterBody2D
@export var speed: float = 250.0
@export var jump_force: float = -650.0

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += 1800.0 * delta

	# Ground controls
	if is_on_floor():
		# Auto-face opponent
		if opponent:
			$Visuals.scale.x = 1 if opponent.global_position.x > global_position.x else -1

		# Crouch or Move/Jump
		if Input.is_action_pressed(prefix + "down"):
			velocity.x = 0.0
		else:
			velocity.x = Input.get_axis(prefix + "left", prefix + "right") * speed
			if Input.is_action_just_pressed(prefix + "up"):
				velocity.y = jump_force

	move_and_slide()
