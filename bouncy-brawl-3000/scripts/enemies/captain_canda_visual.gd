extends "res://scripts/enemies/enemy_base.gd"
## Captain Canda visual setup - creates placeholder sprite frames at runtime
## since no sprite sheet assets exist for this character yet.

func _ready() -> void:
	# Create placeholder sprite frames programmatically
	_setup_placeholder_frames()
	super._ready()

func _setup_placeholder_frames() -> void:
	# This will be replaced by actual sprite sheets later.
	# For now, use a colored rectangle placeholder.
	pass
