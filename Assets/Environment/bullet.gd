extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_bullet_hitbox_area_entered(area: Area2D) -> void:
	print("Bullet hit " + area.name)
	if get_tree().get_nodes_in_group("Enemies"):
		queue_free()


func _on_bullet_hitbox_body_entered(body: Node2D) -> void:
	print("Bullet hit body " + body.name)
	if get_tree().get_nodes_in_group("Environment"):
		queue_free()
