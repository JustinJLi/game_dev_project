extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $Sprite2D

const lines: Array[String] = [
	"A crumbled note...",
	"Instructions:",
	"Eliminate all enemies.",
	"Rescue all hostages.",
	"Come home alive."
]

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	DialogueManager.start_dialog(global_position, lines)
	await DialogueManager.dialog_finished
