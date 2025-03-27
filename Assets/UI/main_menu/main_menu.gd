extends Node2D
@onready var menu_buttons: VBoxContainer = $MenuButtons
@onready var menu_title: Label = $MenuTitle
@onready var options_menu: Control = $CanvasLayer/OptionsMenu


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	options_menu.exit_options_menu.connect(on_exit_options_menu)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:   
	pass


func _on_start_game_pressed() -> void:
	print("Start pressed")
	get_tree().change_scene_to_file("res://Assets/Environment/tutorial.tscn")
	PlayerData.reset()


func _on_options_pressed() -> void:
	print("Options pressed")
	#get_tree().change_scene_to_file("res://Assets/UI/options_menu/options_menu.tscn")	
	menu_buttons.visible = false
	menu_title.visible = false
	options_menu.set_process(true)
	options_menu.visible = true
	
	
func on_exit_options_menu():
	menu_buttons.visible = true
	menu_title.visible = true
	options_menu.set_process(false)
	options_menu.visible = false
	

func _on_exit_pressed() -> void:
	print("Exit pressed")
	get_tree().quit()
