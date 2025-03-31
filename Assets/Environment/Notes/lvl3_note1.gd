extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $Sprite2D

const lines: Array[String] = [
	'"Test Notes:"',
	'"Subject A exceeded performance metrics. +500% efficiency over previous subjects."',
	'"Discard subject B tests. Focus on Subject A enhancements on remaining subjects."',
	'"- J.J."'
]

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	get_tree().paused = true
	DialogueManager.start_dialog(global_position, lines)
	await DialogueManager.dialog_finished
	get_tree().paused = false
