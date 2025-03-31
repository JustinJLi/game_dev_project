extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $Sprite2D

const lines: Array[String] = [
	"A scientist's note, drawn in a hurry.",
	'"EVACUATE IMMEDIATELY!"',
	'"PATHOGEN T-ALPHA HAS BEEN RELEASED"',
	'"ESCAPE NOW IF YOU WANT TO LIVE"'
]

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	get_tree().paused = true
	DialogueManager.start_dialog(global_position, lines)
	await DialogueManager.dialog_finished
	get_tree().paused = false
