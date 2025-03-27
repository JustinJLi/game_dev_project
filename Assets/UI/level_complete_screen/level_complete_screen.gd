extends Node2D
@onready var enemies_killed_score: Label = $EnemiesKilledScore
@onready var hostages_rescued_score: Label = $HostagesRescuedScore
@onready var total_score: Label = $"Total Score"
@onready var hostages_killed_score: Label = $HostagesKilledScore
#var total_score_points = 0
#var enemies_killed_points = 0
#var hostages_rescued_points = 0
#var hostages_killed_points = 0
@onready var enemy = get_tree().get_first_node_in_group("Enemies")
@onready var hostage = get_tree().get_first_node_in_group("Hostages") as hostage
var levels = [
	"res://Assets/Environment/world.tscn",
	"res://Assets/Environment/level_2.tscn",
	"res://Assets/Environment/level_3.tscn",
	"res://Assets/Environment/level_4.tscn",
	"res://Assets/Environment/level_5.tscn"
]

var current_level_index = 0  # Track which level the player is on
@onready var upgrade_screen: Node2D = $"../../CanvasLayer4/UpgradeScreen"
@onready var level_complete_screen: Node2D = $"."


#@onready var upgrade_screen = get_parent().get_node("CanvasLayer4/UpgradeScreen")  
#@onready var level_complete_screen = get_parent().get_node("CanvasLayer2/LevelCompleteScreen")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Reset the score
	reset_scores()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_total_score()
# Reset the scores when transitioning to a new level
func reset_scores():
	#Global.total_score_points = 0
	Global.enemies_killed_points = 0
	Global.hostages_rescued_points = 0
	Global.hostages_killed_points = 0
	
	# Check if enemy exists before accessing it
	if enemy != null:
		EnemyStats.enemies_cleared = 0
		EnemyStats.enemies_killed_score = 0
	
	# Check if hostage exists before accessing it
	if hostage != null:
		hostage.hostages_rescued = 0
		hostage.hostages_rescued_score = 0
		hostage.hostages_killed = 0
		hostage.hostages_killed_score = 0
		hostage.total_hostages_cleared = 0

	# Update scores based on their current values
	if enemy != null:
		update_enemies_killed_score(EnemyStats.enemies_cleared, EnemyStats.enemies_killed_score)
	if hostage != null:
		update_hostages_rescued_score(hostage.hostages_rescued, hostage.hostages_rescued_score)
		update_hostages_killed_score(hostage.hostages_killed, hostage.hostages_killed_score)
		
	update_total_score()



func update_enemies_killed_score(num_enemies : int, score : int):
	Global.enemies_killed_points = score
	enemies_killed_score.text = "Enemies Killed: " + str(num_enemies) + " = " + str(score) + " points"

func update_hostages_rescued_score(num_hostages : int, score : int):
	Global.hostages_rescued_points = score
	hostages_rescued_score.text = "Hostages Rescued: " + str(num_hostages) + " = " + str(score) + " points"

func update_hostages_killed_score(num_hostages_killed : int, score : int):
	Global.hostages_killed_points = score
	hostages_killed_score.text = "Hostages Killed: " + str(num_hostages_killed) + " = " + str(score) + " points"

func update_total_score():
	Global.total_score_points = Global.enemies_killed_points + Global.hostages_rescued_points + Global.hostages_killed_points
	if Global.total_score_points <= 0:
		Global.total_score_points = 0
	total_score.text = "Total Score: " + str(Global.total_score_points)


func _on_next_level_pressed() -> void:
	# Get the current scene path
	var current_scene_path = get_tree().current_scene.scene_file_path

	# Find the index of the current scene in the levels array
	var index = levels.find(current_scene_path)

	# If the current scene is found and not the last level, load the next level
	if index != -1 and index < levels.size() - 1:
		current_level_index = index + 1
		get_tree().change_scene_to_file(levels[current_level_index])
	else:
		print("No more levels! Returning to main menu.")
		PlayerData.reset()
		get_tree().change_scene_to_file("res://Assets/UI/main_menu/main_menu.tscn")  # Go back to main menu


func _on_exit_to_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/UI/main_menu/main_menu.tscn")


func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()
	EnemyStats.reset()


func _on_purchase_upgrades_button_pressed() -> void:
	level_complete_screen.hide()
	upgrade_screen.show()
