extends Control

# Reference to the OptionButton node inside the HBoxContainer
@onready var option_button: OptionButton = $HBoxContainer/OptionButton

# Dictionary mapping resolution labels to actual resolution values (Vector2i)
const RESOLUTION_DICTIONARY : Dictionary = {
	"1280 x 720" : Vector2i(1280, 720),
	"1920 x 1080" : Vector2i(1920, 1080),
	"2560 x 1440" : Vector2i(2560, 1440),
	"3840 x 2160" : Vector2i(3840, 2160),
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the selection event of the OptionButton to a function
	option_button.item_selected.connect(on_resolution_selected)
	
	# Populate the dropdown with resolution options
	add_resolution_items()

# Adds resolution options to the OptionButton
func add_resolution_items():
	for resolution_size_text in RESOLUTION_DICTIONARY:
		option_button.add_item(resolution_size_text)

# Callback function triggered when an item in the OptionButton is selected
func on_resolution_selected(index : int):
	# Change the window resolution based on the selected option
	DisplayServer.window_set_size(RESOLUTION_DICTIONARY.values()[index])

# Called every frame
func _process(delta: float) -> void:
	pass
