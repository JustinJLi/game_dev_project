extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#If a bullet hit either an enemy or hostage, delete the bullet from the scene
func _on_bullet_hitbox_area_entered(area: Area2D) -> void:
	print("Bullet hit " + area.name)
	if get_tree().get_nodes_in_group("Enemies") or get_tree().get_nodes_in_group("Hostages"):
		queue_free()

#If a bullet hit a wall, delete the bullet from the scene
func _on_bullet_hitbox_body_entered(body: Node2D) -> void:
	print("Bullet hit body " + body.name)
	if get_tree().get_nodes_in_group("Environment"):
		queue_free()
