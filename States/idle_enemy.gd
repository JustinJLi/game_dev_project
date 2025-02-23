extends State
class_name idle_enemy

var move_direction : Vector2
var wander_time : float

@export var enemy: CharacterBody2D
@export var move_speed := 50.0
@export var max_detection_range := 200
var detection_range : int

var player: CharacterBody2D

func randomize_wander():
	move_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	wander_time = randf_range(-1,3)
	
func Enter():
	player = get_tree().get_first_node_in_group("Player")
	randomize_wander()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	detection_range = max_detection_range


# Called every frame. 'delta' is the elapsed time since the previous frame.
func Update(delta: float):
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()

func Physics_Update(delta: float) -> void:
	if enemy:
		enemy.velocity = move_direction * move_speed
		
		if move_direction.length() > 0:
			enemy.rotation = move_direction.angle()
		
	var direction = player.global_position - enemy.global_position
	
	if direction.length() < detection_range:
		print("Detected!")
		#$Detected.play()
		Transitioned.emit(self, "Follow")
