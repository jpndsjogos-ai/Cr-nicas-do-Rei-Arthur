extends Node
## UpgradeSystem (Autoload)
## Núcleo do diferencial do jogo: progressão visual de armadura e arma.
## Cada estágio altera cor, escala e atributos do personagem.
## Troque os valores de "color" por texturas/sprites reais quando a arte
## final estiver pronta — a estrutura de dados continua a mesma.

signal armor_upgraded(new_stage: int)
signal weapon_upgraded(new_stage: int)

const ARMOR_STAGES := [
	{
		"name": "Roupas de Couro",
		"color": Color(0.55, 0.4, 0.25),
		"scale": 1.0,
		"defense_bonus": 0,
		"cost": 0,
	},
	{
		"name": "Armadura de Bronze",
		"color": Color(0.72, 0.55, 0.3),
		"scale": 1.03,
		"defense_bonus": 5,
		"cost": 50,
	},
	{
		"name": "Armadura de Aço",
		"color": Color(0.75, 0.78, 0.82),
		"scale": 1.06,
		"defense_bonus": 12,
		"cost": 150,
	},
	{
		"name": "Armadura Rúnica",
		"color": Color(0.4, 0.65, 0.95),
		"scale": 1.1,
		"defense_bonus": 22,
		"cost": 350,
	},
	{
		"name": "Armadura Lendária",
		"color": Color(0.95, 0.8, 0.25),
		"scale": 1.15,
		"defense_bonus": 35,
		"cost": 700,
		"has_glow": true,
	},
]

const WEAPON_STAGES := [
	{
		"name": "Espada Curta",
		"color": Color(0.6, 0.6, 0.6),
		"length_scale": 1.0,
		"damage_bonus": 0,
		"cost": 0,
	},
	{
		"name": "Espada de Ferro",
		"color": Color(0.75, 0.75, 0.78),
		"length_scale": 1.1,
		"damage_bonus": 4,
		"cost": 60,
	},
	{
		"name": "Espada de Aço Nobre",
		"color": Color(0.85, 0.85, 0.9),
		"length_scale": 1.2,
		"damage_bonus": 9,
		"cost": 180,
	},
	{
		"name": "Lâmina Élfica",
		"color": Color(0.5, 0.9, 0.7),
		"length_scale": 1.3,
		"damage_bonus": 16,
		"cost": 400,
	},
	{
		"name": "Excalibur Lendária",
		"color": Color(0.95, 0.85, 0.3),
		"length_scale": 1.45,
		"damage_bonus": 28,
		"cost": 800,
		"has_glow": true,
	},
]

var current_armor_stage: int = 0
var current_weapon_stage: int = 0


func get_armor_data() -> Dictionary:
	return ARMOR_STAGES[current_armor_stage]


func get_weapon_data() -> Dictionary:
	return WEAPON_STAGES[current_weapon_stage]


func can_upgrade_armor() -> bool:
	return current_armor_stage < ARMOR_STAGES.size() - 1


func can_upgrade_weapon() -> bool:
	return current_weapon_stage < WEAPON_STAGES.size() - 1


func try_upgrade_armor() -> bool:
	if not can_upgrade_armor():
		return false
	var next_stage: Dictionary = ARMOR_STAGES[current_armor_stage + 1]
	if GameManager.spend_coins(next_stage["cost"]):
		current_armor_stage += 1
		armor_upgraded.emit(current_armor_stage)
		return true
	return false


func try_upgrade_weapon() -> bool:
	if not can_upgrade_weapon():
		return false
	var next_stage: Dictionary = WEAPON_STAGES[current_weapon_stage + 1]
	if GameManager.spend_coins(next_stage["cost"]):
		current_weapon_stage += 1
		weapon_upgraded.emit(current_weapon_stage)
		return true
	return false


func get_total_defense_bonus() -> int:
	return ARMOR_STAGES[current_armor_stage]["defense_bonus"]


func get_total_damage_bonus() -> int:
	return WEAPON_STAGES[current_weapon_stage]["damage_bonus"]
