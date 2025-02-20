extends State
class_name hostage_follow

var player: CharacterBody2D

@export var hostage: CharacterBody2D
@export var move_speed := 150.0

func Enter():
	player = get_tree().get_first_node_in_group("Player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func Physics_Update(delta: float):
	var direction = player.global_position - hostage.global_position
	
	if direction.length() > 25:
		hostage.velocity = direction.normalized() * move_speed
		hostage.look_at(player.position)
	else:
		hostage.velocity = Vector2()
		
	if direction.length() < 55: #Stop moving during dialogue
		hostage.velocity = Vector2()
	
	if direction.length() > 200:
		Transitioned.emit(self, "Idle")
