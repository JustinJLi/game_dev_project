extends Control

@onready var exit_button: Button = $MarginContainer/VBoxContainer/ExitButton

signal exit_options_menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	exit_button.button_down.connect(on_exit_pressed)
	set_process(false)

func on_exit_pressed():
	#get_tree().change_scene_to_file("res://Assets/UI/main_menu/main_menu.tscn")	
	exit_options_menu.emit()
	set_process(false)




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		on_exit_pressed()
