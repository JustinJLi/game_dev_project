extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $Sprite2D

const lines: Array[String] = [
	"Day 4. Testing Grounds.",
	"A biological agent has spread throughout the laboratory.",
	"Locate the missing scientist held hostage.",
	"Enemy sentry turrets have been deployed. Exercise caution..."
]

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	get_tree().paused = true
	DialogueManager.start_dialog(global_position, lines)
	await DialogueManager.dialog_finished
	get_tree().paused = false
