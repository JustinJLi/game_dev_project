extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_turret_bullet_hitbox_area_entered(area: Area2D) -> void:
	print("Turret bullet hit " + area.name)
	if get_tree().get_nodes_in_group("Enemies") or get_tree().get_nodes_in_group("Hostages") or get_tree().get_nodes_in_group("Player"):
		queue_free()


func _on_turret_bullet_hitbox_body_entered(body: Node2D) -> void:
	print("Turret bullet hit body " + body.name)
	if get_tree().get_nodes_in_group("Environment"):
		queue_free()
