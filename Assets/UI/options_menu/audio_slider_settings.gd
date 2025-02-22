extends Control
@onready var audio_name_label: Label = $HBoxContainer/AudioNameLabel as Label
@onready var audio_num_label: Label = $HBoxContainer/AudioNumLabel as Label
@onready var h_slider: HSlider = $HBoxContainer/HSlider as HSlider

@export_enum("Master", "Music", "SFX") var bus_name : String

var bus_index : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	h_slider.value_changed.connect(on_value_changed)
	get_bus_name_by_index()
	set_name_label_text()
	set_slider_value()

func set_name_label_text():
	audio_name_label.text = str(bus_name) + " Volume"

func set_audio_num_label_text():
	audio_num_label.text = str(h_slider.value * 100) + "%"

func get_bus_name_by_index():
	bus_index = AudioServer.get_bus_index(bus_name)

func on_value_changed(value : float):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	set_audio_num_label_text()

func set_slider_value():
	h_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	set_audio_num_label_text()

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
