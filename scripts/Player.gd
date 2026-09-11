extends CharacterBody2D
## Player.gd
## Controla movimento, ataque em combo, bloqueio e a aplicação visual
## dos estágios de armadura/arma vindos do UpgradeSystem.

const SPEED := 160.0
const ATTACK_COOLDOWN := 0.35
const COMBO_WINDOW := 0.6
const SPECIAL_COST := 100  # energia necessária para o golpe especial

@onready var body_sprite: ColorRect = $BodySprite
@onready var weapon_sprite: ColorRect = $WeaponSprite
@onready var glow: PointLight2D = $Glow
@onready var attack_area: Area2D = $AttackArea
@onready var attack_collision: CollisionShape2D = $AttackArea/CollisionShape2D

var facing_direction: int = 1
var is_attacking: bool = false
var combo_step: int = 0
var combo_timer: float = 0.0
var attack_cooldown_timer: float = 0.0
var special_energy: float = 0.0
var is_blocking: bool = false

var base_damage: int = 10


func _ready() -> void:
	attack_collision.disabled = true
	add_to_group("player")
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	apply_visual_upgrades()
	UpgradeSystem.armor_upgraded.connect(func(_s): apply_visual_upgrades())
	UpgradeSystem.weapon_upgraded.connect(func(_s): apply_visual_upgrades())


func _physics_process(delta: float) -> void:
	_handle_timers(delta)
	_handle_movement()
	move_and_slide()


func _handle_timers(delta: float) -> void:
	if attack_cooldown_timer > 0.0:
		attack_cooldown_timer -= delta
	if combo_timer > 0.0:
		combo_timer -= delta
	else:
		combo_step = 0


func _handle_movement() -> void:
	if is_attacking or is_blocking:
		velocity = Vector2.ZERO
		return

	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()

	if input_vector.x != 0:
		facing_direction = sign(input_vector.x)
		scale.x = abs(scale.x) * facing_direction

	velocity = input_vector * SPEED


## Chamado pelos botões de toque (ou teclas de debug no PC)
func do_attack() -> void:
	if attack_cooldown_timer > 0.0 or is_blocking:
		return

	is_attacking = true
	attack_cooldown_timer = ATTACK_COOLDOWN
	combo_timer = COMBO_WINDOW
	combo_step = (combo_step % 3) + 1

	attack_collision.disabled = false
	special_energy = min(100.0, special_energy + 8.0)

	await get_tree().create_timer(0.15).timeout
	attack_collision.disabled = true
	is_attacking = false


func do_special_attack() -> void:
	if special_energy < SPECIAL_COST or is_attacking:
		return
	special_energy = 0.0
	is_attacking = true
	attack_collision.disabled = false
	# Golpe especial causa 3x o dano base
	await get_tree().create_timer(0.3).timeout
	attack_collision.disabled = true
	is_attacking = false


func set_blocking(value: bool) -> void:
	is_blocking = value


## Chamado pelos inimigos ao acertar o jogador. Aplica redução de dano
## vinda da armadura equipada e repassa para o GameManager (que também
## atualiza a HUD via sinal).
func take_damage(amount: int, _source_position: Vector2) -> void:
	if is_blocking:
		amount = int(amount * 0.25)
	else:
		var defense: int = UpgradeSystem.get_total_defense_bonus()
		amount = max(1, amount - int(defense * 0.5))
	GameManager.damage_player(amount)


func get_current_damage() -> int:
	var multiplier := 1.0 + (0.25 * (combo_step - 1))
	return int((base_damage + UpgradeSystem.get_total_damage_bonus()) * multiplier)


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(get_current_damage(), global_position)


## Aplica os dados do estágio atual de armadura/arma ao visual do personagem.
## Substitua ColorRect por AnimatedSprite2D/Sprite2D quando tiver a arte final:
## basta trocar body_sprite.color por body_sprite.texture = load(stage.texture_path)
func apply_visual_upgrades() -> void:
	var armor: Dictionary = UpgradeSystem.get_armor_data()
	var weapon: Dictionary = UpgradeSystem.get_weapon_data()

	body_sprite.color = armor["color"]
	scale = Vector2.ONE * armor["scale"] * facing_direction if facing_direction < 0 else Vector2.ONE * armor["scale"]

	weapon_sprite.color = weapon["color"]
	weapon_sprite.scale.x = weapon["length_scale"]

	glow.visible = armor.get("has_glow", false) or weapon.get("has_glow", false)

	GameManager.set_max_health(100 + armor["defense_bonus"] * 2)
