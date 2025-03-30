extends Node2D

# References to UI elements
@onready var menu_buttons: VBoxContainer = $MenuButtons
@onready var menu_title: Label = $MenuTitle
@onready var options_menu: Control = $CanvasLayer/OptionsMenu

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Connect the exit signal from the options menu to a function that restores the main menu
	options_menu.exit_options_menu.connect(on_exit_options_menu)

# Called every frame (currently unused)
func _process(delta: float) -> void:   
	pass

# Handles the start game button press
func _on_start_game_pressed() -> void:
	print("Start pressed")  # Debugging output
	get_tree().change_scene_to_file("res://Assets/Environment/tutorial.tscn")  # Load the tutorial scene
	PlayerData.reset()  # Reset player data when starting a new game

# Handles the options button press
func _on_options_pressed() -> void:
	print("Options pressed")  # Debugging output

	# Hide the main menu buttons and title
	menu_buttons.visible = false
	menu_title.visible = false

	# Show and activate the options menu
	options_menu.set_process(true)
	options_menu.visible = true

# Handles exiting the options menu and returning to the main menu
func on_exit_options_menu():
	# Restore main menu visibility
	menu_buttons.visible = true
	menu_title.visible = true

	# Hide and deactivate the options menu
	options_menu.set_process(false)
	options_menu.visible = false

# Handles the exit button press to quit the game
func _on_exit_pressed() -> void:
	print("Exit pressed")  # Debugging output
	get_tree().quit()  # Quit the game
