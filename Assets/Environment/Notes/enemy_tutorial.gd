extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $Sprite2D

const lines: Array[String] = [
	"The enemy faction.",
	"They will patrol the area until they find you...",
	"Eliminate them before they do.",
]

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	DialogueManager.start_dialog(global_position, lines)
	await DialogueManager.dialog_finished
