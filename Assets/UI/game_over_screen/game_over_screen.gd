extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Function to handle when the player exits to the main menu.
func _on_exit_to_main_menu_pressed() -> void:
	# Changes the scene to the main menu when the button is pressed.
	get_tree().change_scene_to_file("res://Assets/UI/main_menu/main_menu.tscn")

# Function to restart the current level (assumed to be a tutorial level).
func _on_restart_pressed() -> void:
	# Reloads the tutorial scene when the restart button is pressed.
	get_tree().change_scene_to_file("res://Assets/Environment/tutorial.tscn")
	
	# Resets player data to its initial state.
	PlayerData.reset()
