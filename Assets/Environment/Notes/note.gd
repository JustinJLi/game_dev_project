extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $Sprite2D
var player: CharacterBody2D

const lines: Array[String] = [
	"Instructions:",
	"Eliminate all enemies.",
	"Rescue all hostages.",
	"Come home alive."
]

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	get_tree().paused = true
	DialogueManager.start_dialog(global_position, lines)
	await DialogueManager.dialog_finished
	get_tree().paused = false
