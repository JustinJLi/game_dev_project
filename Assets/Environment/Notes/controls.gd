extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $Sprite2D

const lines: Array[String] = [
	"A crumbled note...",
	"Controls:",
	"WASD to move.",
	"Hold left shift to sprint.",
	"Left click to attack.",
	"R to reload.",
	"F to toggle flashlight.",
	"Q or scroll mouse to switch weapons.",
	"Watch your ammo."
]

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	get_tree().paused = true
	DialogueManager.start_dialog(global_position, lines)
	await DialogueManager.dialog_finished
	get_tree().paused = false
