extends Control

# References to UI elements
@onready var exit_button: Button = $MarginContainer/VBoxContainer/ExitButton

# Signal for notifying when the options menu is exited
signal exit_options_menu

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Connect the exit button press event to the on_exit_pressed function
	exit_button.button_down.connect(on_exit_pressed)
	
	# Disable processing to prevent unnecessary frame updates
	set_process(false)

# Handles the exit button press or the pause action
func on_exit_pressed():
	# Emit the exit signal to notify other parts of the game that the options menu is exiting
	exit_options_menu.emit()

	# Disable processing as we are exiting or pausing
	set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame
func _process(delta: float) -> void:
	# If the pause action is triggered, call the exit logic
	if Input.is_action_just_pressed("pause"):
		on_exit_pressed()
