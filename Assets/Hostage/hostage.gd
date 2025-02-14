extends CharacterBody2D
class_name hostage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	var player = get_parent().get_node("Player")
	look_at(player.position)

func _on_hostage_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "bullet_hitbox":
			queue_free()
		


func _on_hostage_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player":
			queue_free()
