extends State
class_name hostage_follow

var player: CharacterBody2D #Instance of the player

#Hostage instance and movement speed 
@export var hostage: CharacterBody2D
@export var move_speed := 150.0

func Enter():
	player = get_tree().get_first_node_in_group("Player") #Get the player in the level

# Called every frame. 'delta' is the elapsed time since the previous frame.
func Physics_Update(delta: float):
	var direction = player.global_position - hostage.global_position #calculate distance from player and hostage
	
	#If the player and hostage are close enough to each other, look at the player and walk towards him 
	if direction.length() > 25:
		hostage.velocity = direction.normalized() * move_speed
		hostage.look_at(player.position)
	else:
		hostage.velocity = Vector2() #otherwise stand still
		
	if direction.length() < 55: #Stop moving during dialogue
		hostage.velocity = Vector2()
	
	if direction.length() > 200: #If the player is far enough, go back to idle state
		Transitioned.emit(self, "Idle")
