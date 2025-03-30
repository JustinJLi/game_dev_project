extends Control

# References to UI elements inside the HBoxContainer
@onready var audio_name_label: Label = $HBoxContainer/AudioNameLabel as Label
@onready var audio_num_label: Label = $HBoxContainer/AudioNumLabel as Label
@onready var h_slider: HSlider = $HBoxContainer/HSlider as HSlider

# Exposed property allowing selection of the audio bus (Master, Music, or SFX)
@export_enum("Master", "Music", "SFX") var bus_name : String

# Stores the index of the selected audio bus
var bus_index : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect slider value change signal to the function that handles it
	h_slider.value_changed.connect(on_value_changed)
	
	# Get the corresponding audio bus index
	get_bus_name_by_index()
	
	# Set the label text based on the selected bus
	set_name_label_text()
	
	# Set the slider value based on the current bus volume
	set_slider_value()

# Sets the label text to display the selected audio bus name
func set_name_label_text():
	audio_name_label.text = str(bus_name) + " Volume"

# Updates the numerical label to show the volume percentage
func set_audio_num_label_text():
	audio_num_label.text = str(h_slider.value * 100) + "%"

# Retrieves the index of the selected audio bus from the AudioServer
func get_bus_name_by_index():
	bus_index = AudioServer.get_bus_index(bus_name)

# Handles slider value changes and updates the audio bus volume
func on_value_changed(value : float):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	set_audio_num_label_text()

# Sets the slider's initial value based on the current volume of the selected audio bus
func set_slider_value():
	h_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	set_audio_num_label_text()

# Called every frame
func _process(delta: float) -> void:
	pass
