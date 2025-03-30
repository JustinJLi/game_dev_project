extends Node2D

# References to UI labels displaying score values
@onready var enemies_killed_score: Label = $EnemiesKilledScore
@onready var hostages_rescued_score: Label = $HostagesRescuedScore
@onready var total_score: Label = $"Total Score"
@onready var hostages_killed_score: Label = $HostagesKilledScore

# References to upgrade and level complete screens
@onready var upgrade_screen: Node2D = $"../../CanvasLayer4/UpgradeScreen"
@onready var level_complete_screen: Node2D = $"."

# Get references to enemy and hostage nodes
@onready var enemy = get_tree().get_first_node_in_group("Enemies")
@onready var hostage = get_tree().get_first_node_in_group("Hostages") as hostage

# List of all level paths in the game
var levels = [
	"res://Assets/Environment/world.tscn",
	"res://Assets/Environment/level_2.tscn",
	"res://Assets/Environment/level_3.tscn",
	"res://Assets/Environment/level_4.tscn",
	"res://Assets/Environment/level_5.tscn"
]

var current_level_index = 0  # Track the current level index


# Called when the node enters the scene tree for the first time
func _ready() -> void:
	reset_scores()  # Reset scores when initializing

# Called every frame (currently unused)
func _process(delta: float) -> void:
	pass

# Reset the scores when transitioning to a new level
func reset_scores():
	Global.enemies_killed_points = 0
	Global.hostages_rescued_points = 0
	Global.hostages_killed_points = 0
	
	# Reset enemy-related stats if an enemy exists
	if enemy != null:
		EnemyStats.enemies_cleared = 0
		EnemyStats.enemies_killed_score = 0
	
	# Reset hostage-related stats if a hostage exists
	if hostage != null:
		hostage.hostages_rescued = 0
		hostage.hostages_rescued_score = 0
		hostage.hostages_killed = 0
		hostage.hostages_killed_score = 0
		hostage.total_hostages_cleared = 0

	# Update scores based on the reset values
	if enemy != null:
		update_enemies_killed_score(EnemyStats.enemies_cleared, EnemyStats.enemies_killed_score)
	if hostage != null:
		update_hostages_rescued_score(hostage.hostages_rescued, hostage.hostages_rescued_score)
		update_hostages_killed_score(hostage.hostages_killed, hostage.hostages_killed_score)
		
	update_total_score()

# Updates the UI for enemies killed
func update_enemies_killed_score(num_enemies : int, score : int):
	Global.enemies_killed_points = score
	enemies_killed_score.text = "Enemies Killed: " + str(num_enemies) + " = " + str(score) + " points"

# Updates the UI for hostages rescued
func update_hostages_rescued_score(num_hostages : int, score : int):
	Global.hostages_rescued_points = score
	hostages_rescued_score.text = "Hostages Rescued: " + str(num_hostages) + " = " + str(score) + " points"

# Updates the UI for hostages killed
func update_hostages_killed_score(num_hostages_killed : int, score : int):
	Global.hostages_killed_points = score
	hostages_killed_score.text = "Hostages Killed: " + str(num_hostages_killed) + " = " + str(score) + " points"

# Calculates and updates the total score for the level
func update_total_score():
	Global.total_score_points += Global.enemies_killed_points + Global.hostages_rescued_points + Global.hostages_killed_points
	var total_score_for_level = Global.enemies_killed_points + Global.hostages_rescued_points + Global.hostages_killed_points
	
	# Prevent negative score display
	if Global.total_score_points <= 0:
		Global.total_score_points = 0
	if total_score_for_level <= 0:
		total_score_for_level = 0
	
	total_score.text = "Total Score: " + str(total_score_for_level)

# Handles the transition to the next level
func _on_next_level_pressed() -> void:
	var current_scene_path = get_tree().current_scene.scene_file_path  # Get current scene path
	var index = levels.find(current_scene_path)  # Find current level index

	# If the current level exists and it's not the last one, load the next level
	if index != -1 and index < levels.size() - 1:
		current_level_index = index + 1
		get_tree().change_scene_to_file(levels[current_level_index])
	else:
		print("No more levels! Returning to main menu.")
		PlayerData.reset()
		get_tree().change_scene_to_file("res://Assets/UI/main_menu/main_menu.tscn")  # Return to main menu

# Returns to the main menu
func _on_exit_to_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/UI/main_menu/main_menu.tscn")

# Restarts the current level
func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()
	EnemyStats.reset()

# Displays the upgrade screen when the purchase upgrades button is pressed
func _on_purchase_upgrades_button_pressed() -> void:
	level_complete_screen.hide()
	upgrade_screen.show()
