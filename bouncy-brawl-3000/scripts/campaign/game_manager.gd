extends Node
## Autoload singleton managing the campaign state, healing timer, and fight transitions.

signal fight_started(fight_index: int)
signal fight_ended(player_won: bool)
signal heal_tick()

enum FightState { NONE, FIGHTING, PAUSED, VICTORY, DEFEAT }

var combat_config: CombatConfig = CombatConfig.new()
var current_fight: int = 0  # 0=Mage, 1=Canda, 2=Shoebum
var fight_state: FightState = FightState.NONE

var _heal_timer: float = 0.0
var _fight_active: bool = false

var player_stats: FighterStats = null
var enemy_stats: FighterStats = null

const BOSS_NAMES: Array[String] = ["Mage", "Captain Canda", "Shoebum"]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if fight_state != FightState.FIGHTING:
		return
	# Healing timer
	_heal_timer += delta
	if _heal_timer >= combat_config.heal_interval:
		_heal_timer -= combat_config.heal_interval
		heal_tick.emit()

func start_fight(index: int) -> void:
	current_fight = index
	fight_state = FightState.FIGHTING
	_heal_timer = 0.0
	_fight_active = true
	fight_started.emit(index)

func end_fight(player_won: bool) -> void:
	if player_won:
		fight_state = FightState.VICTORY
	else:
		fight_state = FightState.DEFEAT
	_fight_active = false
	fight_ended.emit(player_won)

func pause_fight() -> void:
	if fight_state == FightState.FIGHTING:
		fight_state = FightState.PAUSED

func resume_fight() -> void:
	if fight_state == FightState.PAUSED:
		fight_state = FightState.FIGHTING

func get_boss_name() -> String:
	if current_fight >= 0 and current_fight < BOSS_NAMES.size():
		return BOSS_NAMES[current_fight]
	return "Unknown"

func has_next_fight() -> bool:
	return current_fight < 2

func reset_for_retry() -> void:
	_heal_timer = 0.0
	fight_state = FightState.FIGHTING
	_fight_active = true
