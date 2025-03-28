extends State
class_name idle_enemy

#variables to allow random "wandering" movement during patrol state
var move_direction : Vector2
var wander_time : float

#Enemy instance + stats
@export var enemy: CharacterBody2D
@export var move_speed := 50.0
@export var max_detection_range := 300
var detection_range : int

var player: CharacterBody2D #player instance

#Function to randomize the direction and wandering time of the enemy during patrol
func randomize_wander():
	move_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	wander_time = randf_range(-1,3)
	
func Enter():
	player = get_tree().get_first_node_in_group("Player") #Get player in level
	randomize_wander() #Begin randomizing their speed and direction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	detection_range = max_detection_range #Set detection range

# Called every frame. 'delta' is the elapsed time since the previous frame.
func Update(delta: float):
	#Keep randomizing wander during this state
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()

func Physics_Update(delta: float) -> void:
	#Give enemy their movement speed and rotation during patrol
	if enemy:
		enemy.velocity = move_direction * move_speed
		
		if move_direction.length() > 0:
			enemy.rotation = move_direction.angle()
		
	var direction = player.global_position - enemy.global_position
	
	#If the enemy spotted the player, transition to follow state
	if enemy.player_spotted:
		print("Detected!")
		#$Detected.play()
		Transitioned.emit(self, "Follow")
