extends CanvasLayer
## HUD.gd
## Interface em tela: barra de vida, contador de moedas e os botões de
## toque (ataque, especial, bloqueio). Conecta-se aos sinais do
## GameManager para atualizar automaticamente.

@onready var health_bar: ProgressBar = $Root/TopBar/HealthBar
@onready var coin_label: Label = $Root/TopBar/CoinLabel
@onready var stage_label: Label = $Root/TopBar/StageLabel

@onready var attack_button: Button = $Root/Controls/AttackButton
@onready var special_button: Button = $Root/Controls/SpecialButton
@onready var block_button: Button = $Root/Controls/BlockButton

var player: Node2D = null


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

	GameManager.player_health_changed.connect(_on_health_changed)
	GameManager.coins_changed.connect(_on_coins_changed)
	GameManager.stage_completed.connect(_on_stage_completed)

	_on_health_changed(GameManager.player_current_health, GameManager.player_max_health)
	_on_coins_changed(GameManager.coins)

	attack_button.pressed.connect(func(): player.do_attack())
	special_button.pressed.connect(func(): player.do_special_attack())
	block_button.button_down.connect(func(): player.set_blocking(true))
	block_button.button_up.connect(func(): player.set_blocking(false))


func _on_health_changed(current: int, max_health: int) -> void:
	health_bar.max_value = max_health
	health_bar.value = current


func _on_coins_changed(amount: int) -> void:
	coin_label.text = "Moedas: %d" % amount


func _on_stage_completed(stage_index: int) -> void:
	stage_label.text = "Fase %d concluída!" % (stage_index + 1)
