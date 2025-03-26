extends Node2D


# Assuming you have a TextureRect node to display the map
@onready var fullscreen_map = $FullscreenMap
@onready var map_texture = preload("res://Assets/UI/map_images/lvl_1_map.png")

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
