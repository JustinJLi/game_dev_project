extends State
class_name enemy_follow

var player: CharacterBody2D

@export var enemy: CharacterBody2D
@export var move_speed := 150.0
@export var max_detection_range := 400
var detection_range : int
var nav_agent: NavigationAgent2D
var timer: float = 0.0
var timeout: float = 5.0 

func Enter():
	player = get_tree().get_first_node_in_group("Player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	detection_range = max_detection_range
	nav_agent = enemy.get_node_or_null("NavigationAgent2D")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func Physics_Update(delta: float):
	var direction = nav_agent.get_next_path_position() - enemy.global_position
	
	if enemy.player_spotted:
		nav_agent.target_position = player.global_position
		timer = 0.0  
		enemy.look_at(player.global_position)
	else:
		enemy.look_at(nav_agent.get_next_path_position())
		
	enemy.velocity = direction.normalized() * move_speed
	

	# If player is far enough away from detection range
	if direction.length() > detection_range:
		print("Lost the player")
		enemy.player_spotted = false
		Transitioned.emit(self, "Idle")

	# Timer check to reset detection state (if enemy gets stuck on geometry, for example)
	timer += delta
	if timer >= timeout: 
		print("Timeout: Lost the player")
		enemy.player_spotted = false
		Transitioned.emit(self, "Idle")

func _on_navigation_agent_2d_navigation_finished() -> void:
	if !enemy.player_spotted:
		print("Lost the player")
		enemy.player_spotted = false
		Transitioned.emit(self, "Idle")
