extends Node2D
## Arena scene controller: manages fight setup, fighter spawning, bounce platforms,
## and transitions between campaign fights.

const PLAYER_SCENE = preload("res://scenes/entities/player.tscn")
const MAGE_SCENE = preload("res://scenes/enemies/mage.tscn")
const CANDA_SCENE = preload("res://scenes/enemies/captain_canda.tscn")
const SHOEBUM_SCENE = preload("res://scenes/enemies/shoebum.tscn")

const BOSS_SCENES: Array[PackedScene] = []

@onready var hud: CanvasLayer = $BattleHUD
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var fight_result: CanvasLayer = $FightResult

var player: CharacterBody2D = null
var enemy: CharacterBody2D = null

# Spawn positions on the main platform
var player_spawn: Vector2 = Vector2(420, 144)
var enemy_spawn: Vector2 = Vector2(660, 144)

func _ready() -> void:
	fight_result.retry_requested.connect(_on_retry)
	fight_result.continue_requested.connect(_on_next_fight)
	_start_current_fight()

func _start_current_fight() -> void:
	# Clean up previous fighters
	if player:
		player.queue_free()
		player = null
	if enemy:
		enemy.queue_free()
		enemy = null

	# Spawn player
	player = PLAYER_SCENE.instantiate()
	player.global_position = player_spawn
	add_child(player)

	# Spawn enemy
	match GameManager.current_fight:
		0:
			enemy = MAGE_SCENE.instantiate()
		1:
			enemy = CANDA_SCENE.instantiate()
		2:
			enemy = SHOEBUM_SCENE.instantiate()
		_:
			enemy = MAGE_SCENE.instantiate()

	enemy.global_position = enemy_spawn
	add_child(enemy)

	# Connect enemy to player reference
	enemy.player = player

	# Connect death signals
	player.died.connect(_on_player_died)
	enemy.died.connect(_on_enemy_died)

	# Setup HUD
	hud.setup(player.stats, enemy.stats, GameManager.get_boss_name())

	# Start the fight
	GameManager.start_fight(GameManager.current_fight)

func _on_player_died() -> void:
	GameManager.end_fight(false)
	await get_tree().create_timer(1.0).timeout
	fight_result.show_defeat()

func _on_enemy_died() -> void:
	GameManager.end_fight(true)
	await get_tree().create_timer(1.0).timeout
	if GameManager.has_next_fight():
		fight_result.show_victory()
	else:
		fight_result.show_victory()

func _on_retry() -> void:
	GameManager.reset_for_retry()
	_start_current_fight()

func _on_next_fight() -> void:
	GameManager.current_fight += 1
	_start_current_fight()
