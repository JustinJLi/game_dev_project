extends Control

# Reference to the OptionButton in the UI for selecting window modes
@onready var option_button: OptionButton = $HBoxContainer/OptionButton

# Array containing different window mode options
const WINDOW_MODE_ARRAY : Array[String] = [
	"Full-Screen",
	"Windowed",
	"Borderless Window",
	"Borderless Full-Screen"
]

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	add_window_mode_items()  # Populate the OptionButton with window mode options
	option_button.item_selected.connect(on_window_mode_selected)  # Connect selection signal

# Adds the available window mode options to the OptionButton dropdown
func add_window_mode_items():
	for window_mode in WINDOW_MODE_ARRAY:
		option_button.add_item(window_mode)

# Called when a window mode is selected from the dropdown
func on_window_mode_selected(index : int):
	match index:
		0:  # Full-Screen mode
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1:  # Windowed mode
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		2:  # Borderless Window (Resizable window without borders)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		3:  # Borderless Full-Screen (Fullscreen without window borders)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

# Called every frame
func _process(delta: float) -> void:
	pass  
