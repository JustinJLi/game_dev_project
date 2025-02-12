extends State
class_name enemy_follow

var player: CharacterBody2D

@export var enemy: CharacterBody2D
@export var move_speed := 100.0

func Enter():
	player = get_tree().get_first_node_in_group("Player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func Physics_Update(delta: float):
	var direction = player.global_position - enemy.global_position
	
	if direction.length() > 25:
		enemy.velocity = direction.normalized() * move_speed
		enemy.look_at(player.position)
	else:
		enemy.velocity = Vector2()
		
	if direction.length() > 200:
		print("Lost the player")
		Transitioned.emit(self, "Idle")
