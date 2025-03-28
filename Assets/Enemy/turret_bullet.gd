extends RigidBody2D

#Retrieve instance of the player and set the damage of the turret bullet
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")
@export var turret_damage = 25

#Function that occurs whenever a turret bullet hits something
func _on_turret_bullet_hitbox_area_entered(area: Area2D) -> void:
	print("Turret bullet hit " + area.name)
	
	#Delete the bullet if hit hits any player or hostage or enemy
	if get_tree().get_nodes_in_group("Enemies") or get_tree().get_nodes_in_group("Hostages") or get_tree().get_nodes_in_group("Player"):
		queue_free()
	
	#If the bullet hits the player, make them take damage
	if area.name == "player_hitbox":
		if !player.level_completed:
			player.take_damage(turret_damage)

#Delete any bullets that hit the environment geometry
func _on_turret_bullet_hitbox_body_entered(body: Node2D) -> void:
	print("Turret bullet hit body " + body.name)
	if get_tree().get_nodes_in_group("Environment"):
		queue_free()
