extends RigidBody2D

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")
@onready var healthbar = get_parent().get_node("CanvasLayer/HUD/HealthBar")
@export var turret_damage = 15

func _on_turret_bullet_hitbox_area_entered(area: Area2D) -> void:
	print("Turret bullet hit " + area.name)
	
	if get_tree().get_nodes_in_group("Enemies") or get_tree().get_nodes_in_group("Hostages") or get_tree().get_nodes_in_group("Player"):
		queue_free()
		
	if area.name == "player_hitbox":
		var player = get_tree().get_first_node_in_group("Player")
		if !player.level_completed:
			player.take_damage(turret_damage)


func _on_turret_bullet_hitbox_body_entered(body: Node2D) -> void:
	print("Turret bullet hit body " + body.name)
	if get_tree().get_nodes_in_group("Environment"):
		queue_free()
