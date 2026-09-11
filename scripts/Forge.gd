extends Control
## Forge.gd
## Tela de "forja" acessada entre fases: mostra o estágio atual de
## armadura/arma, o próximo estágio disponível, o custo em moedas e
## aplica a atualização visual imediatamente ao confirmar.

@onready var armor_name_label: Label = $Panel/VBox/ArmorRow/ArmorName
@onready var armor_cost_label: Label = $Panel/VBox/ArmorRow/ArmorCost
@onready var armor_button: Button = $Panel/VBox/ArmorRow/ArmorUpgradeButton

@onready var weapon_name_label: Label = $Panel/VBox/WeaponRow/WeaponName
@onready var weapon_cost_label: Label = $Panel/VBox/WeaponRow/WeaponCost
@onready var weapon_button: Button = $Panel/VBox/WeaponRow/WeaponUpgradeButton

@onready var coin_label: Label = $Panel/VBox/CoinLabel


func _ready() -> void:
	armor_button.pressed.connect(_on_armor_upgrade_pressed)
	weapon_button.pressed.connect(_on_weapon_upgrade_pressed)
	GameManager.coins_changed.connect(func(_c): _refresh())
	_refresh()


func _refresh() -> void:
	coin_label.text = "Moedas disponíveis: %d" % GameManager.coins

	var armor: Dictionary = UpgradeSystem.get_armor_data()
	armor_name_label.text = "Armadura atual: %s" % armor["name"]

	if UpgradeSystem.can_upgrade_armor():
		var next_armor: Dictionary = UpgradeSystem.ARMOR_STAGES[UpgradeSystem.current_armor_stage + 1]
		armor_cost_label.text = "Próxima: %s (%d moedas)" % [next_armor["name"], next_armor["cost"]]
		armor_button.disabled = GameManager.coins < next_armor["cost"]
		armor_button.text = "Evoluir Armadura"
	else:
		armor_cost_label.text = "Nível máximo atingido!"
		armor_button.disabled = true

	var weapon: Dictionary = UpgradeSystem.get_weapon_data()
	weapon_name_label.text = "Arma atual: %s" % weapon["name"]

	if UpgradeSystem.can_upgrade_weapon():
		var next_weapon: Dictionary = UpgradeSystem.WEAPON_STAGES[UpgradeSystem.current_weapon_stage + 1]
		weapon_cost_label.text = "Próxima: %s (%d moedas)" % [next_weapon["name"], next_weapon["cost"]]
		weapon_button.disabled = GameManager.coins < next_weapon["cost"]
		weapon_button.text = "Evoluir Arma"
	else:
		weapon_cost_label.text = "Nível máximo atingido!"
		weapon_button.disabled = true


func _on_armor_upgrade_pressed() -> void:
	UpgradeSystem.try_upgrade_armor()
	_refresh()


func _on_weapon_upgrade_pressed() -> void:
	UpgradeSystem.try_upgrade_weapon()
	_refresh()
