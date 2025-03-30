extends Node2D

# References to other UI elements and the player
@onready var player = $"../.."
@onready var menu_buttons: VBoxContainer = $MenuButtons
@onready var menu_title: Label = $MenuTitle
@onready var options_menu: Control = $CanvasLayer/OptionsMenu

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Connect the exit options menu signal to the on_exit_options_menu function
	options_menu.exit_options_menu.connect(on_exit_options_menu)

# Called every frame. 'delta' is the elapsed time since the previous frame
func _process(delta: float) -> void:
	pass

# Handles the resume button press
func _on_resume_pressed() -> void:
	print("Resume pressed")
	player.pauseMenu()

# Handles the options button press
func _on_options_pressed() -> void:
	print("Options pressed")
	# Hides menu buttons and title, shows the options menu
	menu_buttons.visible = false
	menu_title.visible = false
	options_menu.set_process(true)  # Starts processing the options menu
	options_menu.visible = true  # Makes the options menu visible

# Handles the exit of the options menu, called via the signal
func on_exit_options_menu():
	# Resets visibility of menu buttons and title, stops processing options menu
	menu_buttons.visible = true
	menu_title.visible = true
	options_menu.set_process(false)  # Stops processing options menu
	options_menu.visible = false  # Hides the options menu

# Handles the exit button press
func _on_exit_pressed() -> void:
	print("Exit pressed")
	get_tree().quit()  # Quits the game or application
