extends CharacterBody2D
## Enemy.gd
## Inimigo padrão: persegue o jogador, ataca quando perto, morre e dropa
## moedas. Serve de base para variações (arqueiro, escudeiro, etc.) via
## export vars ajustáveis no editor por cena/instância.

@export var max_health: int = 30
@export var speed: float = 90.0
@export var attack_damage: int = 8
@export var attack_range: float = 40.0
@export var coin_drop: int = 10

@onready var sprite: ColorRect = $BodySprite
@onready var attack_timer: Timer = $AttackTimer

var current_health: int
var player_ref: Node2D = null
var can_attack: bool = true


func _ready() -> void:
	current_health = max_health
	player_ref = get_tree().get_first_node_in_group("player")
	attack_timer.timeout.connect(_on_attack_timer_timeout)


func _physics_process(_delta: float) -> void:
	if player_ref == null or current_health <= 0:
		return

	var distance := global_position.distance_to(player_ref.global_position)

	if distance > attack_range:
		var direction := (player_ref.global_position - global_position).normalized()
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
		_try_attack()

	move_and_slide()


func _try_attack() -> void:
	if can_attack and player_ref.has_method("take_damage"):
		player_ref.take_damage(attack_damage, global_position)
		can_attack = false
		attack_timer.start(1.2)


func _on_attack_timer_timeout() -> void:
	can_attack = true


func take_damage(amount: int, _source_position: Vector2) -> void:
	current_health -= amount
	sprite.modulate = Color(1, 0.4, 0.4)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE

	if current_health <= 0:
		die()


func die() -> void:
	GameManager.add_coins(coin_drop)
	queue_free()
