extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $Sprite2D

const lines: Array[String] = [
	"A printed document.",
	'"Getting the Truth Out: Bernstein Bradley"',
	'"Do not trust the military!"',
	'"They will send your loved ones to their death!"',
	"The remaining pages are illegible..."
]

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	get_tree().paused = true
	DialogueManager.start_dialog(global_position, lines)
	await DialogueManager.dialog_finished
	get_tree().paused = false
