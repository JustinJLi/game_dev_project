extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $Sprite2D
@onready var hud = get_parent().get_node("HUD")  
@onready var player = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	hud = get_tree().get_first_node_in_group("hud")

func _on_interact():
	player.total_ammo += 24
	hud.update_bullet_label(player.ammo, player.total_ammo)
	PlayerData.ammo = player.ammo
	PlayerData.total_ammo = player.total_ammo
	$Ammo.play()
	await $Ammo.finished
	queue_free()
