extends "res://scripts/Enemy.gd"
## Boss.gd
## Chefe de fase: herda toda a lógica de Enemy.gd, mas com vida/dano
## maiores e um segundo padrão de ataque (investida) ativado quando a
## vida cai abaixo de 50%.

@export var enraged_speed_multiplier: float = 1.8
var is_enraged: bool = false


func take_damage(amount: int, source_position: Vector2) -> void:
	super.take_damage(amount, source_position)
	if not is_enraged and current_health <= max_health * 0.5:
		_enter_enrage()


func _enter_enrage() -> void:
	is_enraged = true
	speed *= enraged_speed_multiplier
	sprite.modulate = Color(1.0, 0.6, 0.6)


func die() -> void:
	GameManager.complete_stage()
	super.die()
