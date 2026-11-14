extends CanvasLayer
## Battle HUD showing both fighters' health, stamina, and names.

@onready var player_name_label: Label = $PlayerHUD/PlayerName
@onready var player_health_bar: ProgressBar = $PlayerHUD/HealthBar
@onready var player_health_value: Label = $PlayerHUD/HealthValue
@onready var player_stamina_bar: ProgressBar = $PlayerHUD/StaminaBar

@onready var enemy_name_label: Label = $EnemyHUD/EnemyName
@onready var enemy_health_bar: ProgressBar = $EnemyHUD/HealthBar
@onready var enemy_health_value: Label = $EnemyHUD/HealthValue
@onready var enemy_stamina_bar: ProgressBar = $EnemyHUD/StaminaBar

@onready var heal_indicator: Label = $HealIndicator

var player_stats: FighterStats = null
var enemy_stats: FighterStats = null

var _heal_flash_timer: float = 0.0

func _ready() -> void:
	GameManager.heal_tick.connect(_on_heal_tick)

func setup(p_stats: FighterStats, e_stats: FighterStats, enemy_name: String) -> void:
	player_stats = p_stats
	enemy_stats = e_stats

	player_name_label.text = "Knight"
	enemy_name_label.text = enemy_name

	# Connect signals
	player_stats.health_changed.connect(_on_player_health_changed)
	player_stats.stamina_changed.connect(_on_player_stamina_changed)
	enemy_stats.health_changed.connect(_on_enemy_health_changed)
	enemy_stats.stamina_changed.connect(_on_enemy_stamina_changed)

	# Initialize
	_update_player_health(player_stats.health, player_stats.max_health)
	_update_player_stamina(player_stats.stamina, player_stats.max_stamina)
	_update_enemy_health(enemy_stats.health, enemy_stats.max_health)
	_update_enemy_stamina(enemy_stats.stamina, enemy_stats.max_stamina)

func _process(delta: float) -> void:
	if _heal_flash_timer > 0.0:
		_heal_flash_timer -= delta
		if _heal_flash_timer <= 0.0:
			heal_indicator.visible = false

func _on_player_health_changed(current: float, maximum: float) -> void:
	_update_player_health(current, maximum)

func _on_player_stamina_changed(current: float, maximum: float) -> void:
	_update_player_stamina(current, maximum)

func _on_enemy_health_changed(current: float, maximum: float) -> void:
	_update_enemy_health(current, maximum)

func _on_enemy_stamina_changed(current: float, maximum: float) -> void:
	_update_enemy_stamina(current, maximum)

func _update_player_health(current: float, maximum: float) -> void:
	if player_health_bar:
		player_health_bar.max_value = maximum
		player_health_bar.value = current
	if player_health_value:
		player_health_value.text = str(int(current)) + " / " + str(int(maximum))

func _update_player_stamina(current: float, maximum: float) -> void:
	if player_stamina_bar:
		player_stamina_bar.max_value = maximum
		player_stamina_bar.value = current

func _update_enemy_health(current: float, maximum: float) -> void:
	if enemy_health_bar:
		enemy_health_bar.max_value = maximum
		enemy_health_bar.value = current
	if enemy_health_value:
		enemy_health_value.text = str(int(current)) + " / " + str(int(maximum))

func _update_enemy_stamina(current: float, maximum: float) -> void:
	if enemy_stamina_bar:
		enemy_stamina_bar.max_value = maximum
		enemy_stamina_bar.value = current

func _on_heal_tick() -> void:
	heal_indicator.visible = true
	heal_indicator.text = "♥ HEAL +15 HP ♥"
	_heal_flash_timer = 2.0
