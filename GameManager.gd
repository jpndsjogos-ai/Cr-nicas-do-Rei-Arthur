extends Node
## GameManager (Autoload)
## Guarda o estado global da partida: moedas, fase atual, vida do jogador
## e dados de progresso que precisam sobreviver entre trocas de cena.

signal coins_changed(new_amount: int)
signal player_health_changed(current: int, max_health: int)
signal game_over
signal stage_completed(stage_index: int)

var coins: int = 0
var current_stage_index: int = 0
var total_stages: int = 6

var player_max_health: int = 100
var player_current_health: int = 100


func add_coins(amount: int) -> void:
	coins += amount
	coins_changed.emit(coins)


func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		coins_changed.emit(coins)
		return true
	return false


func damage_player(amount: int) -> void:
	player_current_health = max(0, player_current_health - amount)
	player_health_changed.emit(player_current_health, player_max_health)
	if player_current_health <= 0:
		game_over.emit()


func heal_player(amount: int) -> void:
	player_current_health = min(player_max_health, player_current_health + amount)
	player_health_changed.emit(player_current_health, player_max_health)


func set_max_health(new_max: int) -> void:
	player_max_health = new_max
	player_current_health = new_max
	player_health_changed.emit(player_current_health, player_max_health)


func complete_stage() -> void:
	stage_completed.emit(current_stage_index)
	current_stage_index += 1


func reset_run() -> void:
	coins = 0
	current_stage_index = 0
	player_current_health = player_max_health
