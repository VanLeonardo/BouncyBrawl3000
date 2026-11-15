class_name CombatConfig
extends Resource
## Central place for all combat balance values.
## Tweak these to adjust game feel.

# --- Attack values ---
## Damage dealt by knight melee
@export var knight_attack_damage: float = 15.0
## Stamina cost of knight melee
@export var knight_attack_stamina: float = 18.0
## Knockback percent added per hit
@export var knight_knockback_add: float = 8.0

## Mage fireball damage
@export var mage_fireball_damage: float = 12.0
## Mage fireball stamina cost
@export var mage_fireball_stamina: float = 25.0
## Mage fireball knockback add
@export var mage_fireball_knockback: float = 6.0
## Mage fireball speed
@export var mage_fireball_speed: float = 350.0
## Mage fireball cooldown seconds
@export var mage_fireball_cooldown: float = 2.5

## Captain Canda shield damage
@export var canda_shield_damage: float = 14.0
## Captain Canda shield stamina cost
@export var canda_shield_stamina: float = 30.0
## Captain Canda shield knockback add
@export var canda_shield_knockback: float = 7.0
## Captain Canda shield throw speed
@export var canda_shield_speed: float = 400.0
## Captain Canda shield cooldown seconds
@export var canda_shield_cooldown: float = 3.0

## Shoebum slap damage
@export var shoebum_slap_damage: float = 18.0
## Shoebum slap stamina cost
@export var shoebum_slap_stamina: float = 20.0
## Shoebum slap knockback add
@export var shoebum_slap_knockback: float = 10.0
## Shoebum slap cooldown seconds
@export var shoebum_slap_cooldown: float = 1.8

## Shoebum stomp damage per pulse
@export var shoebum_stomp_damage: float = 8.0
## Shoebum stomp stamina cost
@export var shoebum_stomp_stamina: float = 35.0
## Shoebum stomp knockback add per pulse
@export var shoebum_stomp_knockback: float = 5.0
## Shoebum stomp cooldown seconds
@export var shoebum_stomp_cooldown: float = 5.0
## Shoebum stomp pulse count
@export var shoebum_stomp_pulses: int = 3
## Shoebum stomp pulse interval seconds
@export var shoebum_stomp_pulse_interval: float = 0.4
## Shoebum stomp launch force
@export var shoebum_stomp_launch_force: float = -500.0

# --- Knockback scaling ---
## Base knockback force
@export var knockback_base_force: float = 200.0
## Extra knockback force per 1% knockback
@export var knockback_scaling: float = 5.0

# --- Healing ---
## Seconds between heals
@export var heal_interval: float = 20.0
## HP recovered per interval
@export var heal_amount: float = 15.0

# --- Platform Recovery ---
## Bounce platform upward force
@export var bounce_force: float = -750.0
## Air control multiplier (0-1)
@export var air_control: float = 0.7
## Y position below which fighters are ring-outed
@export var kill_boundary_y: float = 700.0

# --- Movement (shared defaults) ---
@export var move_speed: float = 250.0
@export var jump_force: float = -500.0
@export var gravity: float = 1200.0

func get_knockback_force(knockback_percent: float, direction: Vector2) -> Vector2:
	var force_magnitude = knockback_base_force + knockback_scaling * knockback_percent
	return direction.normalized() * force_magnitude

func calculate_knockback(knockback_percent: float) -> float:
	return knockback_base_force + knockback_scaling * knockback_percent
