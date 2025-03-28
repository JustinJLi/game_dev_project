extends Node

@onready var text_box_scene = preload("res://Assets/Dialogue/Textbox.tscn") #reference to textbox scene

#Paramters for dialog within the textbox (includes the lines, index of which line of dialogue is playing, and more)
var dialog_lines: Array[String] = []
var current_line_index = 0
var dialog_close_delay = 0.0
var text_box
var text_box_position: Vector2

#Booleans used to track if dialog is in progress, or needs to continue
var is_dialog_active = false
var can_advance_line = false

signal dialog_finished()#Signal that activates when dialog is finished

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS  # Dialogue should process even when game is paused

#Function to start dialog with an object
func start_dialog(position: Vector2, lines: Array[String]):
	if is_dialog_active: #Ensure dialog is actually active
		return
	
	#Initialize the text box position and lines of text, and show the text box with these variables	
	dialog_lines = lines
	text_box_position = position
	_show_text_box()
	
	#Set flag true indicating that dialog is about to start
	is_dialog_active = true
	
#Function to show the text box for dialog
func _show_text_box():
	#Instantiate the textbox to hold dialog above the interaction area. Display text line by line based on the lines given
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	get_tree().root.add_child(text_box)
	text_box.global_position = text_box_position
	text_box.display_text(dialog_lines[current_line_index])
	can_advance_line = false
	
#When the text box is done displaying a line of text, set flag to true to continue dialog
func _on_text_box_finished_displaying():
	can_advance_line = true

#Function for input handling
func _unhandled_input(event: InputEvent) -> void:
	#Once dialog is done, remove the textbox and show the next line
	if event.is_action_pressed("advance_dialog") and is_dialog_active and can_advance_line:
		text_box.queue_free()
		
		#Display each line of dialog, continuing through the indexes until the lines are done
		current_line_index += 1
		if current_line_index >= dialog_lines.size():
			is_dialog_active = false
			current_line_index = 0
			dialog_finished.emit()
			dialog_close_delay = Time.get_ticks_msec() + 200
			return
		
		_show_text_box() #Show the text box
