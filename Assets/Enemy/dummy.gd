extends CharacterBody2D
class_name dummy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	var player = get_parent().get_node("Player")
	look_at(player.position)
