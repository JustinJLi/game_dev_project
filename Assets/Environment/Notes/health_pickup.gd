extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $Sprite2D
@onready var hud = get_parent().get_node("HUD")  
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var healthbar = get_parent().get_node("CanvasLayer/HUD/HealthBar")

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	hud = get_tree().get_first_node_in_group("hud")

func _on_interact():
	if player.health < 50:
		player.health += 50
	else:
		player.health += player.max_health - player.health
	healthbar._set_health(player.health)
	hud.update_bullet_label(player.ammo, player.total_ammo)
	queue_free()
