extends CharacterBody2D

var motion = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var Player = get_parent().get_node("Player")
	
	position += (Player.position - position) / 100
	look_at(Player.position)
	
	move_and_collide(motion)
	
	
func kill():
	get_tree().call_deferred("reload_current_scene")

func _on_area_2d_area_entered(area: Area2D) -> void:
	print(area.name)
	if area.name == "bullet_hitbox":
		queue_free()
		
	if area.name == "player_hitbox":
		kill()
