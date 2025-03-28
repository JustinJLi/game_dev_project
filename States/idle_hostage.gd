extends State
class_name idle_hostage

#variables to allow random "wandering" movement during patrol state
var move_direction : Vector2
var wander_time : float

#Hostage instance + stats
@export var hostage: CharacterBody2D
@export var move_speed := 50.0

var player: CharacterBody2D #player instance

#Function to randomize the direction and wandering time of the enemy during patrol
func randomize_wander():
	move_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	wander_time = randf_range(-1,3)
	
func Enter():
	player = get_tree().get_first_node_in_group("Player")#Get player in level
	randomize_wander() #Begin randomizing their speed and direction

# Called every frame. 'delta' is the elapsed time since the previous frame.
func Update(delta: float):
	#Keep randomizing wander during this state
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()

func Physics_Update(delta: float) -> void:
	#Give enemy their movement speed and rotation during their patrol
	if hostage:
		hostage.velocity = move_direction * move_speed
		
		if move_direction.length() > 0:
			hostage.rotation = move_direction.angle()
		
	var direction = player.global_position - hostage.global_position
	
	#If the hostage spotted the player, transition to follow state
	if direction.length() < 100:
		Transitioned.emit(self, "Follow")
