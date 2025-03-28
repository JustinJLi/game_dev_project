extends State
class_name enemy_follow

#retreives the player instance
var player: CharacterBody2D

#Retreives enemy instance and associated stats
@export var enemy: CharacterBody2D
@export var move_speed := 150.0
@export var max_detection_range := 400
var detection_range : int
var nav_agent: NavigationAgent2D
var timer: float = 0.0
var timeout: float = 5.0 

func Enter():
	player = get_tree().get_first_node_in_group("Player") #Get the player in the level

#Set max detection range and navigation agent for enemy
func _ready() -> void:
	detection_range = max_detection_range
	nav_agent = enemy.get_node_or_null("NavigationAgent2D")

func Physics_Update(delta: float):
	var direction = nav_agent.get_next_path_position() - enemy.global_position #calculate direction from the enemy and the next position in their pathfinding
	
	#If the enemy spotted the player, make their target the player's position and start a timeout timer while looking at the player
	if enemy.player_spotted:
		nav_agent.target_position = player.global_position
		timer = 0.0  
		enemy.look_at(player.global_position)
	else: #Otherwise, just keep looking at the path to follow
		enemy.look_at(nav_agent.get_next_path_position())
		
	enemy.velocity = direction.normalized() * move_speed #set enemy movement speed
	

	# If player is far enough away from detection range, the enemy lost them and the player is not spotted anymore
	if direction.length() > detection_range:
		print("Lost the player")
		enemy.player_spotted = false
		Transitioned.emit(self, "Idle")

	# Timer check to reset detection state (if enemy gets stuck on geometry, for example)
	timer += delta
	if timer >= timeout: #If the timer reaches the timeout and the enemy is still in follow state, go back to patrolling
		print("Timeout: Lost the player")
		enemy.player_spotted = false
		Transitioned.emit(self, "Idle")

# Return to patrolling if the player was not found at the end of the navigation path
func _on_navigation_agent_2d_navigation_finished() -> void:
	if !enemy.player_spotted:
		print("Lost the player")
		enemy.player_spotted = false
		Transitioned.emit(self, "Idle")
