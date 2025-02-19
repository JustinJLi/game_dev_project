extends Node2D
@onready var enemies_killed_score: Label = $EnemiesKilledScore
@onready var hostages_rescued_score: Label = $HostagesRescuedScore
@onready var total_score: Label = $"Total Score"
@onready var hostages_killed_score: Label = $HostagesKilledScore
var total_score_points = 0
var enemies_killed_points = 0
var hostages_rescued_points = 0
var hostages_killed_points = 0
@onready var enemy = get_tree().get_first_node_in_group("Enemies")
@onready var hostage = get_tree().get_first_node_in_group("Hostages") as hostage



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Reset the score
	reset_scores()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_total_score()
# Reset the scores when transitioning to a new level
func reset_scores():
	total_score_points = 0
	enemies_killed_points = 0
	hostages_rescued_points = 0
	hostages_killed_points = 0
	
	# Check if enemy exists before accessing it
	if enemy != null:
		enemy.enemies_cleared = 0
		enemy.enemies_killed_score = 0
	
	# Check if hostage exists before accessing it
	if hostage != null:
		hostage.hostages_rescued = 0
		hostage.hostages_rescued_score = 0
		hostage.hostages_killed = 0
		hostage.hostages_killed_score = 0

	# Update scores based on their current values
	if enemy != null:
		update_enemies_killed_score(enemy.enemies_cleared, enemy.enemies_killed_score)
	if hostage != null:
		update_hostages_rescued_score(hostage.hostages_rescued, hostage.hostages_rescued_score)
		update_hostages_killed_score(hostage.hostages_killed, hostage.hostages_killed_score)
		
	update_total_score()



func update_enemies_killed_score(num_enemies : int, score : int):
	enemies_killed_points = score
	enemies_killed_score.text = "Enemies Killed: " + str(num_enemies) + " = " + str(score) + " points"

func update_hostages_rescued_score(num_hostages : int, score : int):
	hostages_rescued_points = score
	hostages_rescued_score.text = "Hostages Rescued: " + str(num_hostages) + " = " + str(score) + " points"

func update_hostages_killed_score(num_hostages_killed : int, score : int):
	hostages_killed_points = score
	hostages_killed_score.text = "Hostages Killed: " + str(num_hostages_killed) + " = " + str(score) + " points"

func update_total_score():
	var total_score_points = enemies_killed_points + hostages_rescued_points + hostages_killed_points
	total_score.text = "Total Score: " + str(total_score_points)


func _on_next_level_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Environment/world.tscn")

func _on_exit_to_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/UI/main_menu/main_menu.tscn")


func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Environment/world.tscn")
