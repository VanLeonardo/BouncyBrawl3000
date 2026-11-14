class_name FighterStats
extends Resource
## Shared resource for fighter health, stamina, and knockback state.
## Used by both player and enemies.

signal health_changed(current: float, maximum: float)
signal stamina_changed(current: float, maximum: float)
signal knockback_changed(percent: float)
signal fighter_died()

@export var max_health: float = 125.0
@export var max_stamina: float = 100.0

var health: float = 125.0
var stamina: float = 100.0
var knockback_percent: float = 0.0

# Stamina regen config
@export var stamina_regen_rate: float = 20.0  # per second
@export var stamina_regen_delay: float = 1.0  # seconds after last attack
var _stamina_regen_timer: float = 0.0

func reset() -> void:
	health = max_health
	stamina = max_stamina
	knockback_percent = 0.0
	_stamina_regen_timer = 0.0
	health_changed.emit(health, max_health)
	stamina_changed.emit(stamina, max_stamina)
	knockback_changed.emit(knockback_percent)

func take_damage(amount: float) -> void:
	health = maxf(health - amount, 0.0)
	health_changed.emit(health, max_health)
	if health <= 0.0:
		fighter_died.emit()

func heal(amount: float) -> void:
	health = minf(health + amount, max_health)
	health_changed.emit(health, max_health)

func use_stamina(amount: float) -> bool:
	if stamina < amount:
		return false
	stamina -= amount
	_stamina_regen_timer = stamina_regen_delay
	stamina_changed.emit(stamina, max_stamina)
	return true

func has_stamina(amount: float) -> bool:
	return stamina >= amount

func add_knockback(amount: float) -> void:
	knockback_percent += amount
	knockback_changed.emit(knockback_percent)

func update_stamina_regen(delta: float) -> void:
	if _stamina_regen_timer > 0.0:
		_stamina_regen_timer -= delta
		return
	if stamina < max_stamina:
		stamina = minf(stamina + stamina_regen_rate * delta, max_stamina)
		stamina_changed.emit(stamina, max_stamina)

func is_dead() -> bool:
	return health <= 0.0
