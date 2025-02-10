extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_bullet_hitbox_area_entered(area: Area2D) -> void:
	print("Bullet hit " + area.name)
	if area.name == "enemy_hitbox":
		queue_free()


func _on_bullet_hitbox_body_entered(body: Node2D) -> void:
	print("Bullet hit body " + body.name)
	if body.name == "white_wall":
		queue_free()
